Class {
	#name : #SLVMLLVMFunctionCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'target',
		'moduleTranslator',
		'function',
		'llvmFunction',
		'valueDictionary',
		'usedNames',
		'functionDebugScope'
	],
	#classVars : [
		'BinaryFloatComparisonOperationMap',
		'BinaryIntegerComparisonOperationMap',
		'BinaryOperationMap',
		'UnaryOperationMap'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #initialization }
SLVMLLVMFunctionCodeGenerator class >> initialize [
	BinaryOperationMap := Dictionary newFromPairs: #(
		add add
		sub sub
		mul mul
		div sdiv
		udiv udiv
		rem srem
		urem urem

		bitand and
		bitor or
		bitxor xor

		shiftleft shl
		shiftright lshr
		shiftrightarithmetic ashr

		fadd fadd
		fsub fsub
		fmul fmul
		fdiv fdiv
		frem frem
	).
	
	BinaryIntegerComparisonOperationMap := Dictionary newFromPairs: #(
		ilt slt
		ile sle
		ieq eq
		ine ne
		igt sgt
		ige sge

		ult ult
		ule ule
		ugt ugt
		uge uge

		dynObjectIdentityEquals eq
		dynObjectIdentityNotEquals ne
	).
	
	BinaryFloatComparisonOperationMap := Dictionary newFromPairs: #(
		uflt ult
		ufle ult
		ufeq ueq
		ufne une
		ufgt ugt
		ufge uge

		oflt olt
		ofle ole
		ofeq oeq
		ofne one
		ofgt ogt
		ofge oge
	).
	
	UnaryOperationMap := Dictionary newFromPairs: #(
		neg		visitUnaryNegation:
		not   visitUnaryNot:
		lnot  visitUnaryLogicalNot:

		fneg   visitUnaryFloatNegation:
		fsqrt  visitUnarySqrt:
	).
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> aggregate: sourceAggregate extractValueAt: sourceIndex [
	^ LLVMExtractValueInst new
		type: (sourceAggregate type memberAt: sourceIndex);
		aggregate: sourceAggregate;
		indices: {sourceIndex};
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> aggregate: sourceAggregate insertValue: value at: destIndex [
	^ LLVMInsertValueInst new
		type: sourceAggregate type;
		aggregate: sourceAggregate;
		element: value;
		indices: {destIndex};
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> constructVectorOfType: resultVectorType byLoading: sourceIndices from: sourceVectors outputStream: out [
	^ self constructVectorOfType: resultVectorType byLoading: sourceIndices withResultSize: sourceVectors size from: sourceVectors outputStream: out
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> constructVectorOfType: resultVectorType byLoading: sourceIndices withResultSize: resultSize from: sourceVectors outputStream: out [
	| firstIndex result secondIndex middlePoint leftIndices rightIndices partitionVectorSize partitionVectorType leftPartitionVector rightPartitionVector joinShuffleMask destIndex firstVector secondVector |
	self assert: sourceIndices size >= 1.
	
	"First base case"
	sourceIndices size = 1 ifTrue: [ 
		firstIndex := sourceIndices first.
		resultSize > 1 ifTrue: [ 
			self assert: resultSize = 2.
			result := self vector: (sourceVectors at: firstIndex first + 1) shuffleWith: (sourceVectors at: firstIndex first + 1)
				mask: { firstIndex second . firstIndex second }
		] ifFalse: [
			result := self vector: (sourceVectors at: firstIndex first + 1) extractElementAt: firstIndex second.
		].

		out nextPut: result.
		^ result
	].

	"Second base case"
	sourceIndices size = 2 ifTrue: [ 
		firstIndex := sourceIndices first.
		secondIndex := sourceIndices second.
		firstVector := sourceVectors at: firstIndex first + 1.
		secondVector := sourceVectors at: secondIndex first + 1.
		self assert: firstVector type = secondVector type.
		result := self vector: firstVector shuffleWith: secondVector
			mask: { firstIndex second . firstVector type elements + secondIndex second }.
		out nextPut: result.
		^ result.
	].

	"Split in two parts"
	middlePoint := sourceIndices size // 2.
	leftIndices := sourceIndices first: middlePoint.
	rightIndices := sourceIndices allButFirst: middlePoint.

	partitionVectorSize := leftIndices size max: rightIndices size.
	partitionVectorType := LLVMVectorType get: resultVectorType elementType elements: partitionVectorSize.
	leftPartitionVector := self constructVectorOfType: partitionVectorType byLoading: leftIndices withResultSize: partitionVectorSize from: sourceVectors outputStream: out.
	rightPartitionVector := self constructVectorOfType: partitionVectorType byLoading: rightIndices withResultSize: partitionVectorSize from: sourceVectors outputStream: out.
	
	joinShuffleMask := Array new: resultSize withAll: 0.
	destIndex := 1.
	1 to: leftIndices size do: [ :i |
		joinShuffleMask at: destIndex put: i - 1.
		destIndex := destIndex + 1
	].
	1 to: rightIndices size do: [ :i |
		joinShuffleMask at: destIndex put: i - 1 + partitionVectorSize.
		destIndex := destIndex + 1
	].
	
	result := self vector: leftPartitionVector shuffleWith: rightPartitionVector mask: joinShuffleMask.
	out nextPut: result.
	^ result
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> context [
	^ moduleTranslator context
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> convertDebugLocationFrom: slvmInstruction into: llvmInstruction [
	functionDebugScope ifNil: [ ^ self ].
	(self convertDebugSourceLocation: slvmInstruction debugSourceLocation debugInformation: slvmInstruction debugInformation) ifNotNil: [ :convertedLocation |
		llvmInstruction addDebugMetadata: convertedLocation
	]
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> convertDebugScope: debugScope [
	debugScope ifNil: [ ^ functionDebugScope ].
	self halt
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> convertDebugSourceLocation: debugSourceLocation debugInformation: debugInformation [
	| debugScope |
	debugSourceLocation ifNil: [ ^ nil ].
	debugScope := self convertDebugScope: (debugInformation ifNotNil: #scope).
	
	^ moduleTranslator convertDebugSourceLocation: debugSourceLocation withScope: debugScope
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> convertDebugVariable: debugInformation [
	^ moduleTranslator convertDebugVariable: debugInformation fallbackScopeInto: functionDebugScope
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> convertName: aName [
	^ aName ifNotNil: [
		aName isLLVMAnon ifTrue: [ nil
		] ifFalse: [
			(usedNames includes: aName) ifTrue: [ nil
			] ifFalse: [
				usedNames add: aName.
				aName
			]
		]
	]
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> createProxyValues [
	| llvmBasicBlock proxy |
	function dominanceTopoSort do: [ :bb |
		llvmBasicBlock := LLVMBasicBlock for: self context name: (self convertName: bb name) parent: llvmFunction.
		valueDictionary at: bb put: llvmBasicBlock.
		
		bb instructionsDo: [ :ins |
			proxy := LLVMInstructionProxy new sourceValue: ins.
			valueDictionary at: ins put: proxy.
			llvmBasicBlock addNext: proxy
		]
	].
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> extractMatrixColumns: sourceMatrixValue into: out [
	| sourceValue sourceColumnType columns column |
	sourceValue := self translateValue: sourceMatrixValue.
	sourceColumnType := self translateType: sourceMatrixValue type columnType.
	columns := sourceMatrixValue type columns.
	^ 	(1 to: columns) collect: [ :i |
		column := self aggregate: sourceValue extractValueAt: i - 1.
		out nextPut: column
	].
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> extractMatrixRows: sourceMatrixValue into: out [
	| sourceValue sourceColumnType columns rows sourceColumns sourceIndices rowType |
	sourceValue := self translateValue: sourceMatrixValue.
	sourceColumnType := self translateType: sourceMatrixValue type columnType.
	rowType := self translateType: sourceMatrixValue type rowType.
	columns := sourceMatrixValue type columns.
	rows := sourceMatrixValue type rows.

	sourceColumns := self extractMatrixColumns: sourceMatrixValue into: out.
	
	^ (1 to: rows) collect: [ :rowIndex |
		sourceIndices := (1 to: columns) collect: [ :columnIndex |
			{ columnIndex - 1 . rowIndex - 1 }
		].

		self constructVectorOfType: rowType byLoading: sourceIndices from: sourceColumns outputStream: out
	].
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> functionDebugScope [
	^ functionDebugScope
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> functionDebugScope: aDebugScope [
	functionDebugScope := aDebugScope
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateBuiltInFunction: builtInFunction call: instruction [
	| generator |
	generator := SLVMLLVMBuiltInFunctionGenerator fromName: builtInFunction name.
	generator ifNil: [ self error: 'Failed to generate built-in function.' ].
	
	^ generator generateWith: self builtInFunction: builtInFunction callInstruction: instruction
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateDot: left with: right mul: multiplyOperation add: additionOperation into: out [
	| multiplication |
	self assert: left type = right type.
	multiplication := self generateScalarVectorBinaryOperation: multiplyOperation resultType: left type left: left right: right name: nil.
	out nextPut: multiplication.
	
	^ self generateVectorFold: multiplication with: additionOperation into: out
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> generateFunction: slvmFunction into: newLLVMFunction [
	slvmFunction isEmpty ifTrue: [ ^ newLLVMFunction ].
	
	function := slvmFunction.
	llvmFunction := newLLVMFunction.
	self
		mapArguments;
		createProxyValues;
		translateBasicBlocks

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateMatrix: transposedMatrixType byTransposing: sourceMatrixValue [
	| resultType destColumnType columns rows result majorComponents |
	resultType := self translateType: transposedMatrixType.
	destColumnType := self translateType: transposedMatrixType columnType.

	columns := sourceMatrixValue type columns.
	rows := sourceMatrixValue type rows.
	self assert: transposedMatrixType rows = columns.
	self assert: transposedMatrixType columns = rows.
	
	result := resultType zeroConstant.
	^ Array streamContents: [ :out |
		majorComponents := transposedMatrixType isColumnMajor ifTrue: [
			self extractMatrixRows: sourceMatrixValue into: out
		] ifFalse: [
			self extractMatrixColumns: sourceMatrixValue into: out
		].
	
		majorComponents doWithIndex: [ :majorComponent :index |
			result := self aggregate: result insertValue: majorComponent at: index - 1.
			out nextPut: result.
		].
	]
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateMatrixBinaryOperation: instruction [
	| leftMatrix rightMatrix resultType result columnType leftColumn rightColumn resultColumn |
	instruction operation == #mulMatrixMatrix ifTrue: [ ^ self generateMatrixTimesMatrix: instruction ].
	instruction operation == #mulVectorMatrix ifTrue: [ ^ self generateVectorTimesMatrix: instruction ].
	instruction operation == #mulMatrixVector ifTrue: [ ^ self generateMatrixTimesVector: instruction ].
	self assert: instruction left type = instruction right type.
	resultType := self translateType: instruction type.
	columnType := self translateType: instruction type columnType.
	leftMatrix := self translateValue: instruction left.
	rightMatrix := self translateValue: instruction right.
	result := resultType zeroConstant.
	^ Array streamContents: [ :out |
		1 to: instruction type columns do: [ :i |
			leftColumn := self aggregate: leftMatrix extractValueAt: i - 1.
			out nextPut: leftColumn.
			
			rightColumn := self aggregate: rightMatrix extractValueAt: i - 1.
			out nextPut: rightColumn.
			
			resultColumn := self generateScalarVectorBinaryOperation: instruction operation resultType: columnType left: leftColumn right: rightColumn name: nil.
			out nextPut: resultColumn.
			
			result := self aggregate: result insertValue: resultColumn at: i -1.
			out nextPut: result.
		]
	].
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateMatrixTimesMatrix: instruction [
"
void matrixMultiply(float left[4][4], float right[4][4], float dest[4][4])
    for(int j = 0; j < 4; ++j)
        for(int k = 0; k < 4; ++k)
            for(int i = 0; i < 4; ++i)
                dest[i][j] += left[i][k]*right[k][j];*/
"

	| rows columns ksize resultType leftColumns rightColumns resultColumn rightScalar leftColumn resultColumnType multiplyOperation columnMultiply additionOperation rightColumn result |
	self assert: instruction type isColumnMajor.
	self assert: instruction left type columns = instruction right type rows.
	
	instruction type isFloatMatrixType ifTrue: [ 
		multiplyOperation := #fmul.
		additionOperation := #fadd.
	] ifFalse: [ 
		self assert: instruction type isIntegerMatrixType.
		multiplyOperation := #mul.
		additionOperation := #add.
	].

	resultType := self translateType: instruction type.
	resultColumnType := self translateType: instruction type columnType.

	rows := instruction type rows.
	columns := instruction type columns.
	ksize := instruction left type columns.
	
	^ Array streamContents: [ :out |
		
		leftColumns := self extractMatrixColumns: instruction left into: out.
		rightColumns := self extractMatrixColumns: instruction right into: out.
		
		result := resultType zeroConstant.
		1 to: columns do: [ :j |
			rightColumn := rightColumns at: j.
			resultColumn := nil.
			1 to: ksize do: [ :k |
				rightScalar := self vector: rightColumn shuffleWith: rightColumn mask: (Array new: rows withAll: k - 1).
				out nextPut: rightScalar.
				
				leftColumn := leftColumns at: k.
				columnMultiply := self generateScalarVectorBinaryOperation: multiplyOperation resultType: resultColumnType left: leftColumn right: rightScalar name: nil.
				out nextPut: columnMultiply.
				
				resultColumn ifNil: [ 
					resultColumn := columnMultiply
				] ifNotNil: [
					resultColumn := self generateScalarVectorBinaryOperation: additionOperation resultType: resultColumnType left: resultColumn right: columnMultiply name: nil.
					out nextPut: resultColumn.
				].
			].
		
			result := self aggregate: result insertValue: resultColumn at: j - 1.
			out nextPut: result
		].
	]
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateMatrixTimesVector: instruction [
"
void matrixMultiply(float matrix[4][4], float vector[4], float result[4])
	for(int k = 0; k < 4; ++k) // Add columns
		for(int i = 0; i < 4; ++i)
			result[i] += matrix[i][k]*vector[k]
"
	| multiplyOperation additionOperation matrixType vectorType resultType matrix vector result multiply resultLLVMType column |
	matrixType := instruction left type.
	vectorType := instruction right type.
	resultType := instruction type.
	resultLLVMType := self translateType: resultType.

	self assert: resultType isVectorType.
	self assert: vectorType isVectorType.
	self assert: matrixType columns = vectorType elements.
	self assert: matrixType rows = resultType elements.
	
	matrixType isFloatMatrixType ifTrue: [ 
		multiplyOperation := #fmul.
		additionOperation := #fadd.
	] ifFalse: [ 
		self assert: matrixType isIntegerMatrixType.
		multiplyOperation := #mul.
		additionOperation := #add.
	].

	matrix := self translateValue: instruction left.
	vector := self translateValue: instruction right.
	^ Array streamContents: [ :out |
		column := self aggregate: matrix extractValueAt: 0.
		out nextPut: column.
		result := self generateScalarVectorBinaryOperation: multiplyOperation
			resultType: resultLLVMType
			left: column
			right: vector name: nil.
		out nextPut: result.
		
		2 to: matrixType columns do: [ :i |
			column := self aggregate: matrix extractValueAt: i - 1.
			out nextPut: column.
			multiply := self generateScalarVectorBinaryOperation: multiplyOperation
				resultType: resultLLVMType
				left: column
				right: vector name: nil.
			out nextPut: multiply.

			result := self generateScalarVectorBinaryOperation: additionOperation
				resultType: resultLLVMType
				left: result
				right: multiply name: nil.
			out nextPut: result.
		]
	]

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateScalarVectorBinaryOperation: operation resultType: resultType left: left right: right name: name [
	BinaryOperationMap at: operation ifPresent: [ :mappedOperation |
		^ LLVMBinaryOperator new
			name: name;
			operation: mappedOperation;
			type: resultType;
			left: left;
			right: right;
			yourself
	].

	BinaryIntegerComparisonOperationMap at: operation ifPresent: [ :mappedOperation |
		^ LLVMICmpInst new
			name: name;
			operation: mappedOperation;
			type: resultType;
			left: left;
			right: right;
			yourself
	].

	BinaryFloatComparisonOperationMap at: operation ifPresent: [ :mappedOperation |
		^ LLVMFCmpInst new
			name: name;
			operation: mappedOperation;
			type: resultType;
			left: left;
			right: right;
			yourself
	].

	self error: 'Unsupported binary operation.'

]

{ #category : #'vector intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateVector: vectorType cross: leftVector with: rightVector [
	"
	https://en.wikipedia.org/wiki/Cross_product#Computing_the_cross_product [ 2018-07-04 23:08 ]
	s1 = u2v3 - u3v2
	s2 = u3v1 - u1v3
	s3 = u1v2 - u2v1
	"
	| leftVectorValue rightVectorValue multiplyOperation subtractionOperation lu lv lm ru rv rm result resultType |
	self assert: leftVector type = rightVector type.
	self assert: leftVector type = vectorType.
	self assert: vectorType elements = 3.
	
	resultType := self translateType: vectorType.
	leftVectorValue := self translateValue: leftVector.
	rightVectorValue := self translateValue: rightVector.
	
	vectorType isFloatVectorType ifTrue: [ 
		multiplyOperation := #fmul.
		subtractionOperation := #fsub.
	] ifFalse: [ 
		self assert: vectorType isIntegerVectorType.
		multiplyOperation := #mul.
		subtractionOperation := #sub.
	].

	^ Array streamContents: [ :out |
		"Left multiply"
		lu := self vector: leftVectorValue shuffleWith: leftVectorValue mask: #(1 2 0). out nextPut: lu.
		lv := self vector: rightVectorValue shuffleWith: rightVectorValue mask: #(2 0 1). out nextPut: lv.
		
		lm := self generateScalarVectorBinaryOperation: multiplyOperation resultType: resultType left: lu right: lv name: nil. out nextPut: lm.
		
		"Right multiply"
		ru := self vector: leftVectorValue shuffleWith: leftVectorValue mask: #(2 0 1). out nextPut: ru.
		rv := self vector: rightVectorValue shuffleWith: rightVectorValue mask: #(1 2 0). out nextPut: rv.
		
		rm := self generateScalarVectorBinaryOperation: multiplyOperation resultType: resultType left: ru right: rv name: nil. out nextPut: rm.
		
		"Subtraction"
		result := self generateScalarVectorBinaryOperation: subtractionOperation resultType: resultType left: lm right: rm name: nil. out nextPut: result.
	]
]

{ #category : #'vector intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateVectorDot: leftVector with: rightVector [
	| vectorType leftVectorValue rightVectorValue multiplyOperation additionOperation |
	self assert: leftVector type = rightVector type.
	vectorType := leftVector type.
	
	leftVectorValue := self translateValue: leftVector.
	rightVectorValue := self translateValue: rightVector.
	
	vectorType isFloatVectorType ifTrue: [ 
		multiplyOperation := #fmul.
		additionOperation := #fadd.
	] ifFalse: [ 
		self assert: vectorType isIntegerVectorType.
		multiplyOperation := #mul.
		additionOperation := #add.
	].

	^ Array streamContents: [ :out |
		self generateDot: leftVectorValue with: rightVectorValue mul: multiplyOperation add: additionOperation into: out
	]
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateVectorFold: vectorOrScalar with: operation into: out [
	| vectorType firstShuffleVector secondShuffleVector halfVectorSize halfVectorType leftIndices rightIndices leftVector rightVector result leftValue rightValue |
	vectorType := vectorOrScalar type.
	vectorOrScalar type isVectorTy ifFalse: [ ^ vectorOrScalar ].
	
	firstShuffleVector := vectorOrScalar.
	secondShuffleVector := vectorType elements even ifTrue: [ vectorOrScalar ] ifFalse: [ vectorType zeroConstant ].
	
	halfVectorSize := (vectorType elements + 1) // 2.
	halfVectorSize = 1 ifTrue: [
		leftValue := self vector: vectorOrScalar extractElementAt: 0.
		out nextPut: leftValue.

		rightValue := self vector: vectorOrScalar extractElementAt: 1.
		out nextPut: rightValue.

		result := self generateScalarVectorBinaryOperation: operation resultType: vectorType elementType left: leftValue right: rightValue name: nil.
		out nextPut: result.
		^ result
	].

	halfVectorType := LLVMVectorType get: vectorType elementType elements: halfVectorSize.
	
	leftIndices := (0 to: halfVectorSize - 1) collect: [ :i | i*2 ].
	rightIndices := (0 to: halfVectorSize - 1) collect: [ :i | i*2 + 1 ].
	
	leftVector := self vector: firstShuffleVector shuffleWith: secondShuffleVector mask: leftIndices.
	out nextPut: leftVector.

	rightVector := self vector: firstShuffleVector shuffleWith: secondShuffleVector mask: rightIndices.
	out nextPut: rightVector.
	
	result := self generateScalarVectorBinaryOperation: operation resultType: halfVectorType left: leftVector right: rightVector name: nil.
	out nextPut: result.
	
	^ self generateVectorFold: result with: operation into: out
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateVectorTimesMatrix: instruction [
"
void matrixMultiply(float vector[4], float matrix[4][4], float result[4])
	for(int k = 0; k < 4; ++k) // Add columns
		for(int i = 0; i < 4; ++i)
			result[k] += vector[i]*matrix[i][k]

"
	| multiplyOperation additionOperation matrixType vectorType resultType matrix vector result resultLLVMType column resultElement |
	vectorType := instruction left type.
	matrixType := instruction right type.
	resultType := instruction type.
	resultLLVMType := self translateType: resultType.

	self assert: resultType isVectorType.
	self assert: vectorType isVectorType.
	self assert: vectorType elements = matrixType rows.
	self assert: matrixType columns = resultType elements.
	
	matrixType isFloatMatrixType ifTrue: [ 
		multiplyOperation := #fmul.
		additionOperation := #fadd.
	] ifFalse: [ 
		self assert: matrixType isIntegerMatrixType.
		multiplyOperation := #mul.
		additionOperation := #add.
	].

	vector := self translateValue: instruction left.
	matrix := self translateValue: instruction right.

	^ Array streamContents: [ :out |
		result := resultLLVMType zeroConstant.
		1 to: resultType elements do: [ :i |
			column := self aggregate: matrix extractValueAt: i - 1.
			out nextPut: column.
			
			resultElement := self generateDot: vector with: column mul: multiplyOperation add: additionOperation into: out.
			result := self vector: result insertElement: resultElement at: i - 1.
			out nextPut: result
		].
	]

]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> initialize [
	super initialize.
	valueDictionary := IdentityDictionary new.
	usedNames := Set new.
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> mapArguments [

	| argumentBaseOffset llvmArgument |
	argumentBaseOffset := 0.
	self flag: 'TODO: Add support for returning structures as arguments'.
	function arguments doWithIndex: [ :arg :index |
		llvmArgument := llvmFunction arguments at: index + argumentBaseOffset.
		llvmArgument name: (self convertName: arg name).
		valueDictionary at: arg put: llvmArgument
	]
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> translateBasicBlocks [
	llvmFunction basicBlocks do: [ :bb |
		bb instructionsReplaceWith: [ :instruction | self translateProxyInstruction: instruction ]
	]
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> translateProxyInstruction: proxyInstruction [
	| original replacement |
	original := proxyInstruction sourceValue.
	replacement := original accept: self.
	replacement isCollection ifTrue: [ 
		replacement ifEmpty: [ 
			valueDictionary at: proxyInstruction sourceValue put: nil
		] ifNotEmpty: [ 
			self convertDebugLocationFrom: original into: replacement first.
			valueDictionary at: proxyInstruction sourceValue put: replacement last
		].
	] ifFalse: [
		self convertDebugLocationFrom: original into: replacement.
		valueDictionary at: proxyInstruction sourceValue put: replacement
	].

	^ replacement
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> translateType: aType [
	^ moduleTranslator translateType: aType
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> translateValue: aValue [
	valueDictionary at: aValue ifPresent: [ :existent | ^ existent ].
	^ moduleTranslator translateValue: aValue
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> vector: sourceVector extractElementAt: sourceIndex [
	^ LLVMExtractElementInst new
		type: sourceVector type elementType;
		vector: sourceVector;
		index: (self context int32Ty constant: sourceIndex);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> vector: sourceVector insertElement: element at: destIndex [
	^ LLVMInsertElementInst new
		type: sourceVector type;
		vector: sourceVector;
		element: element;
		elementIndex: (self context int32Ty constant: destIndex);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> vector: firstVector shuffleWith: secondVector mask: shufleMask [
	| vectorSize vectorType maskValueType maskType mask |
	vectorSize := shufleMask size.
	vectorType := (LLVMVectorType get: firstVector type elementType elements: vectorSize).
	maskValueType := self context int32Ty.
	maskType := (LLVMVectorType get: maskValueType elements: vectorSize).
	mask := maskType constant: (shufleMask collect: [:maskElement | self context int32Ty constant: maskElement]).
	
	^ LLVMShuffleVectorInst new
		type: vectorType;
		firstVector: firstVector;
		secondVector: secondVector;
		mask: mask;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitAlloca: instruction [
	| valueType resultType |
	valueType := self translateType: instruction valueType.
	resultType := self translateType: instruction type.
	^ LLVMAllocaInst new
		name: (self convertName: instruction name);
		type: resultType;
		valueType: valueType;
		alignment: instruction valueType alignment;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitBinaryOperation: instruction [
	instruction isMatrixOperation ifTrue: [ ^ self generateMatrixBinaryOperation: instruction ].
	^ self generateScalarVectorBinaryOperation: instruction operation
		resultType: (self translateType: instruction type)
		left: (self translateValue: instruction left)
		right: (self translateValue: instruction right)
		name: (self convertName: instruction name)

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitBranch: instruction [
	^ LLVMBranchInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		condition: (self translateValue: instruction condition);
		trueDestination: (self translateValue: instruction trueBlock);
		falseDestination: (self translateValue: instruction falseBlock);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitCall: instruction [
	| type calledFunction arguments |
	instruction functionValue isConstantBuiltInFunction ifTrue: [
		^ self generateBuiltInFunction: instruction functionValue call: instruction
	].

	type := self translateType: instruction type.
	
	calledFunction := self translateValue: instruction functionValue.
	arguments := instruction arguments collect: [ :arg | self translateValue: arg ].
	^ LLVMCallInst new
		name: (self convertName: instruction name);
		calledFunction: calledFunction;
		arguments: arguments;
		type: type;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDebugInstructionDeclareVariable: instruction [
	| debugDeclareIntrinsic address localVariable expression |
	debugDeclareIntrinsic := moduleTranslator llvmModule getDebugDeclareIntrinsic.

	address := (self translateValue: instruction variable) asLLVMMetadata asLLVMValueFor: self context.
	localVariable := (self convertDebugVariable: instruction debugInformation) asLLVMValueFor: self context.
	expression := moduleTranslator emptyDebugExpression asLLVMValueFor: self context.

	^ LLVMCallInst new
		name: (self convertName: instruction name);
		calledFunction: debugDeclareIntrinsic;
		arguments: {address . localVariable . expression };
		type: debugDeclareIntrinsic returnType;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDebugInstructionSetVariableValue: instruction [
	| debugValueIntrinsic localVariable expression newValue offset |
	debugValueIntrinsic := moduleTranslator llvmModule getDebugValueIntrinsic.
	newValue := (self translateValue: instruction value) asLLVMMetadata asLLVMValueFor: self context.
	offset := self context int64Ty constant: 0.

	localVariable := (self convertDebugVariable: instruction variable) asLLVMValueFor: self context.
	expression := moduleTranslator emptyDebugExpression asLLVMValueFor: self context.
	
	^ LLVMCallInst new
		name: (self convertName: instruction name);
		calledFunction: debugValueIntrinsic;
		arguments: {newValue . offset . localVariable . expression };
		type: debugValueIntrinsic returnType;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitExtractValue: instruction [
	^ LLVMExtractValueInst new
		name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		aggregate: (self translateValue: instruction aggregate);
		indices: instruction indices;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitExtractVectorElement: instruction [
	^ LLVMExtractElementInst new
		name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		vector: (self translateValue: instruction vector);
		index: (self translateValue: instruction index);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitFloatingPointCast: instruction [
	instruction source type size < instruction type size ifTrue: [ 
		^ LLVMFPExtInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself
	].
	^ LLVMFPTruncInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitGetElementPointer: instruction [
	^ LLVMGetElementPtrInst new
		type: (self translateType: instruction type);
		name: (self convertName: instruction name);
		pointer: (self translateValue: instruction pointer);
		indices: (instruction indices collect: [ :index | self translateValue: index ]);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitIntToFloatCast: instruction [
	instruction source type isSigned ifTrue: [ 
		^ LLVMSIToFPInst new
				type: (self translateType: instruction type);
				name: (self convertName: instruction name);
				source: (self translateValue: instruction source);
				yourself
	].
	^ LLVMUIToFPInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitJump: instruction [
	| destination |
	destination := self translateValue: instruction destination.
	^ LLVMBranchInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		trueDestination: destination;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitLoad: instruction [
	| pointer type |
	type := self translateType: instruction type.
	pointer := self translateValue: instruction variable.
	^ LLVMLoadInst new
		name: (self convertName: instruction name);
		volatile: instruction volatile;
		pointer: pointer;
		type: type;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitMakeMatrix: instruction [
	| matrixType resultInstruction destIndex |
	matrixType := self translateType: instruction type.
	resultInstruction := matrixType zeroConstant.
	destIndex := 0.
	^ Array streamContents: [ :out |
		instruction parameters do: [ :param |
			resultInstruction := self aggregate: resultInstruction
					insertValue: (self translateValue: param) at: destIndex.
				out nextPut: resultInstruction.
				destIndex := destIndex + 1.
		]
	]
	
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitMakeVector: instruction [
	| vectorType resultInstruction destIndex |
	vectorType := self translateType: instruction type.
	resultInstruction := vectorType zeroConstant.
	destIndex := 0.
	^ Array streamContents: [ :out |
		instruction parameters do: [ :param |
			param type isVectorType ifTrue: [
				self halt.
			] ifFalse: [
				resultInstruction := self vector: resultInstruction
					insertElement: (self translateValue: param) at: destIndex.
				out nextPut: resultInstruction.
				destIndex := destIndex + 1.
			]
		]
	].
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitPhi: instruction [
	| result |
	result := LLVMPHINode new
			name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		yourself.
	instruction valuesAndParentsDo: [ :value :parent |
		result addValue: (self translateValue: value) incomingFrom: (self translateValue: parent)
	].

	^ result
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitReturn: instruction [
	^ LLVMReturnInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		value: (self translateValue: instruction value);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitReturnVoid: instruction [
	^ LLVMReturnInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitStore: instruction [
	| pointer value |
	pointer := self translateValue: instruction variable.
	value := self translateValue: instruction value.
	^ LLVMStoreInst new
		name: (self convertName: instruction name);
		volatile: instruction volatile;
		pointer: pointer;
		value: value;
		type: self context voidTy;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryFloatNegation: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	self assert: resultType isFloatingPointTy.
	^ LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #fsub;
			type: resultType;
			left: resultType zeroConstant;
			right: (self translateValue: instruction operand);
			yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryLogicalNot: instruction [
	instruction operand type isBooleanType ifTrue: [ ^ self visitUnaryNot: instruction ].
	^ self halt
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryNegation: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	self assert: resultType isIntegerTy.
	^ LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #sub;
			type: resultType;
			left: resultType zeroConstant;
			right: (self translateValue: instruction operand);
			yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryNot: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	self assert: resultType isIntegerTy.
	^ LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #xor;
			type: resultType;
			left: resultType allOnesConstant;
			right: (self translateValue: instruction operand);
			yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryOperation: instruction [
	^ self perform: (UnaryOperationMap at: instruction operation) with: instruction

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnarySqrt: instruction [
	self halt

]
