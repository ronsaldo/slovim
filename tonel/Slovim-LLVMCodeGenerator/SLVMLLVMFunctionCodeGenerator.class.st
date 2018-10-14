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
		'functionDebugScope',
		'currentBlockBuilder'
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

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> addInstruction: anInstruction [
	^ currentBlockBuilder add: anInstruction
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> aggregate: sourceAggregate extractValueAt: sourceIndex [
	^ self addInstruction: (LLVMExtractValueInst new
		type: (sourceAggregate type memberAt: sourceIndex);
		aggregate: sourceAggregate;
		indices: {sourceIndex};
		yourself)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> aggregate: sourceAggregate insertValue: value at: destIndex [
	^ self addInstruction: (LLVMInsertValueInst new
		type: sourceAggregate type;
		aggregate: sourceAggregate;
		element: value;
		indices: {destIndex};
		yourself)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> bitCast: source target: targetType name: name [
	^ self addInstruction: (LLVMBitCastInst new
			type: targetType;
			name: name;
			source: source;
			yourself)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> call: calledFunction arguments: arguments returnType: returnType name: name [
	^ self call: calledFunction convention: nil arguments: arguments returnType: returnType name: name
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> call: calledFunction convention: callingConvention arguments: arguments returnType: returnType name: name [
	^ self addInstruction: (LLVMCallInst new
		name: name;
		calledFunction: calledFunction;
		arguments: arguments;
		type: returnType;
		callingConvention: callingConvention;
		yourself)
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> callRuntimeFunction: runtimeFunctionOrSymbol arguments: arguments type: typeDefinition [
	| runtimeFunction expectedTypes expectedType castedArguments |
	runtimeFunction := moduleTranslator getOrCreateRuntimeFunction: runtimeFunctionOrSymbol type: typeDefinition.
	
	"We may need to cast the arguments."
	expectedTypes := runtimeFunction functionType params.
	(runtimeFunction functionType isVarArg and: [ arguments size < expectedTypes size ]) ifTrue: [ 
		self error: 'Missing required arguments for runtime function call.'.
	] ifFalse: [ 
		expectedTypes size ~= arguments size ifTrue: [ 
			self error: 'Runtime function call argument count mismatch'.
		].
	].

	castedArguments := arguments collectWithIndex: [ :arg :index |
		expectedType := expectedTypes at: index.
		self castRuntimeCallArgument: arg into: expectedType
	].

	self halt.
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> callRuntimeFunction: runtimeFunctionOrSymbol arguments: arguments type: typeDefinition name: name [
	| runtimeFunction expectedTypes expectedType castedArguments |
	runtimeFunction := moduleTranslator getOrCreateRuntimeFunction: runtimeFunctionOrSymbol type: typeDefinition.
	
	"We may need to cast the arguments."
	expectedTypes := runtimeFunction functionType params.
	(runtimeFunction functionType isVarArg and: [ arguments size < expectedTypes size ]) ifTrue: [ 
		self error: 'Missing required arguments for runtime function call.'.
	] ifFalse: [ 
		expectedTypes size ~= arguments size ifTrue: [ 
			self error: 'Runtime function call argument count mismatch'.
		].
	].

	castedArguments := arguments collectWithIndex: [ :arg :index |
		expectedType := expectedTypes at: index.
		self castRuntimeCallArgument: arg into: expectedType
	].

	^ self call: runtimeFunction
		arguments: castedArguments
		returnType: runtimeFunction returnType
		name: name
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> castRuntimeCallArgument: value into: targetType [
	| sourceType |
	sourceType := value type.
	sourceType == targetType ifTrue: [ ^ value ].
	
	(sourceType isPointerTy and: [ targetType isPointerTy ]) ifTrue: [ 
		^ self bitCast: value target: targetType name: nil
	].
	
	self error: 'Cannot cast runtime argument.'

]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> compare: pointer with: comparisonValue andSwapWith: newValue [
 	| resultType |
	resultType := LLVMStructType context: self context
			elements: {comparisonValue type . self context int1Ty}.

	^ self addInstruction: (LLVMAtomicCmpXchgInst new
			type: resultType;
			pointer: pointer;
			comparisonValue: comparisonValue;
			newValue: newValue;
			yourself).

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> constructVectorOfType: resultVectorType byLoading: sourceIndices from: sourceVectors [
	^ self constructVectorOfType: resultVectorType byLoading: sourceIndices withResultSize: sourceVectors size from: sourceVectors
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> constructVectorOfType: resultVectorType byLoading: sourceIndices withResultSize: resultSize from: sourceVectors [
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
		^ result.
	].

	"Split in two parts"
	middlePoint := sourceIndices size // 2.
	leftIndices := sourceIndices first: middlePoint.
	rightIndices := sourceIndices allButFirst: middlePoint.

	partitionVectorSize := leftIndices size max: rightIndices size.
	partitionVectorType := LLVMVectorType get: resultVectorType elementType elements: partitionVectorSize.
	leftPartitionVector := self constructVectorOfType: partitionVectorType byLoading: leftIndices withResultSize: partitionVectorSize from: sourceVectors.
	rightPartitionVector := self constructVectorOfType: partitionVectorType byLoading: rightIndices withResultSize: partitionVectorSize from: sourceVectors.
	
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
	^ result
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> context [
	^ moduleTranslator context
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> convertCallingConvention: callingConvention [
	^ nil
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

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> doesNotUnderstandTrampolineFor: instruction [
	instruction isDoesNotUnderstandMessage ifTrue: [ 
		^ self nullVoidPointer
	].

	instruction isSuperSend ifTrue: [ self halt ].
	
	^ moduleTranslator doesNotUnderstandTrampolineWithType: instruction doesNotUnderstandTrampolineFunctionType
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> extractMatrixColumns: sourceMatrixValue [
	| sourceValue sourceColumnType columns column |
	sourceValue := self translateValue: sourceMatrixValue.
	sourceColumnType := self translateType: sourceMatrixValue type columnType.
	columns := sourceMatrixValue type columns.
	^ 	(1 to: columns) collect: [ :i |
		column := self aggregate: sourceValue extractValueAt: i - 1.
	].
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> extractMatrixRows: sourceMatrixValue [
	| sourceValue sourceColumnType columns rows sourceColumns sourceIndices rowType |
	sourceValue := self translateValue: sourceMatrixValue.
	sourceColumnType := self translateType: sourceMatrixValue type columnType.
	rowType := self translateType: sourceMatrixValue type rowType.
	columns := sourceMatrixValue type columns.
	rows := sourceMatrixValue type rows.

	sourceColumns := self extractMatrixColumns: sourceMatrixValue.
	
	^ (1 to: rows) collect: [ :rowIndex |
		sourceIndices := (1 to: columns) collect: [ :columnIndex |
			{ columnIndex - 1 . rowIndex - 1 }
		].

		self constructVectorOfType: rowType byLoading: sourceIndices from: sourceColumns
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

{ #category : #'atomic intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateAtomicCompare: sourcePointer with: comparisonValue andSwapWith: newValue returnType: returnType [
	| cmpxchg |
	cmpxchg := self compare: (self translateValue: sourcePointer)
		with: (self translateValue: comparisonValue)
		andSwapWith: (self translateValue: newValue).
		
	^ returnType isBooleanType ifTrue: [
		self aggregate: cmpxchg extractValueAt: 1
	] ifFalse: [
		self aggregate: cmpxchg extractValueAt: 0
	].

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateBuiltInFunction: builtInFunction call: instruction [
	| generator |
	generator := SLVMLLVMBuiltInFunctionGenerator fromName: builtInFunction name.
	generator ifNil: [ self error: 'Failed to generate built-in function.' ].
	
	^ generator generateWith: self builtInFunction: builtInFunction callInstruction: instruction
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateDot: left with: right mul: multiplyOperation add: additionOperation [
	| multiplication |
	self assert: left type = right type.
	multiplication := self generateScalarVectorBinaryOperation: multiplyOperation resultType: left type left: left right: right name: nil.
	
	^ self generateVectorFold: multiplication with: additionOperation
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

	majorComponents := transposedMatrixType isColumnMajor ifTrue: [
		self extractMatrixRows: sourceMatrixValue
	] ifFalse: [
		self extractMatrixColumns: sourceMatrixValue
	].
	
	majorComponents doWithIndex: [ :majorComponent :index |
		result := self aggregate: result insertValue: majorComponent at: index - 1.
	].

	^ result 
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

	1 to: instruction type columns do: [ :i |
		leftColumn := self aggregate: leftMatrix extractValueAt: i - 1.
		rightColumn := self aggregate: rightMatrix extractValueAt: i - 1.
			
		resultColumn := self generateScalarVectorBinaryOperation: instruction operation resultType: columnType left: leftColumn right: rightColumn name: nil.
			
		result := self aggregate: result insertValue: resultColumn at: i -1.
	].

	^ result
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
	
	leftColumns := self extractMatrixColumns: instruction left.
	rightColumns := self extractMatrixColumns: instruction right.
		
	result := resultType zeroConstant.
	1 to: columns do: [ :j |
		rightColumn := rightColumns at: j.
		resultColumn := nil.
		1 to: ksize do: [ :k |
			rightScalar := self vector: rightColumn shuffleWith: rightColumn mask: (Array new: rows withAll: k - 1).
				
			leftColumn := leftColumns at: k.
			columnMultiply := self generateScalarVectorBinaryOperation: multiplyOperation resultType: resultColumnType left: leftColumn right: rightScalar name: nil.
				
			resultColumn ifNil: [ 
				resultColumn := columnMultiply
			] ifNotNil: [
				resultColumn := self generateScalarVectorBinaryOperation: additionOperation resultType: resultColumnType left: resultColumn right: columnMultiply name: nil.
			].
		].
		
		result := self aggregate: result insertValue: resultColumn at: j - 1.
	].

	^ result
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
	
	column := self aggregate: matrix extractValueAt: 0.

	result := self generateScalarVectorBinaryOperation: multiplyOperation
		resultType: resultLLVMType
		left: column
		right: vector name: nil.
		
	2 to: matrixType columns do: [ :i |
		column := self aggregate: matrix extractValueAt: i - 1.
		multiply := self generateScalarVectorBinaryOperation: multiplyOperation
			resultType: resultLLVMType
			left: column
			right: vector name: nil.

		result := self generateScalarVectorBinaryOperation: additionOperation
			resultType: resultLLVMType
			left: result
			right: multiply name: nil.
	].

	^ result

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateScalarVectorBinaryOperation: operation resultType: resultType left: left right: right name: name [
	BinaryOperationMap at: operation ifPresent: [ :mappedOperation |
		^ self addInstruction: (LLVMBinaryOperator new
			name: name;
			operation: mappedOperation;
			type: resultType;
			left: left;
			right: right;
			yourself)
	].

	BinaryIntegerComparisonOperationMap at: operation ifPresent: [ :mappedOperation |
		^ self addInstruction: (LLVMICmpInst new
			name: name;
			operation: mappedOperation;
			type: resultType;
			left: left;
			right: right;
			yourself)
	].

	BinaryFloatComparisonOperationMap at: operation ifPresent: [ :mappedOperation |
		^ self addInstruction: (LLVMFCmpInst new
			name: name;
			operation: mappedOperation;
			type: resultType;
			left: left;
			right: right;
			yourself)
	].

	self error: 'Unsupported binary operation.'

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateSuperMessageSend: instruction [
	self halt
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

	"Left multiply"
	lu := self vector: leftVectorValue shuffleWith: leftVectorValue mask: #(1 2 0).
	lv := self vector: rightVectorValue shuffleWith: rightVectorValue mask: #(2 0 1).
		
	lm := self generateScalarVectorBinaryOperation: multiplyOperation resultType: resultType left: lu right: lv name: nil.
		
	"Right multiply"
	ru := self vector: leftVectorValue shuffleWith: leftVectorValue mask: #(2 0 1).
	rv := self vector: rightVectorValue shuffleWith: rightVectorValue mask: #(1 2 0).
		
	rm := self generateScalarVectorBinaryOperation: multiplyOperation resultType: resultType left: ru right: rv name: nil.
		
	"Subtraction"
	^ self generateScalarVectorBinaryOperation: subtractionOperation resultType: resultType left: lm right: rm name: nil
	
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

	^ self generateDot: leftVectorValue with: rightVectorValue mul: multiplyOperation add: additionOperation
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateVectorFold: vectorOrScalar with: operation [
	| vectorType firstShuffleVector secondShuffleVector halfVectorSize halfVectorType leftIndices rightIndices leftVector rightVector result leftValue rightValue |
	vectorType := vectorOrScalar type.
	vectorOrScalar type isVectorTy ifFalse: [ ^ vectorOrScalar ].
	
	firstShuffleVector := vectorOrScalar.
	secondShuffleVector := vectorType elements even ifTrue: [ vectorOrScalar ] ifFalse: [ vectorType zeroConstant ].
	
	halfVectorSize := (vectorType elements + 1) // 2.
	halfVectorSize = 1 ifTrue: [
		leftValue := self vector: vectorOrScalar extractElementAt: 0.
		rightValue := self vector: vectorOrScalar extractElementAt: 1.

		^ self generateScalarVectorBinaryOperation: operation resultType: vectorType elementType left: leftValue right: rightValue name: nil
	].

	halfVectorType := LLVMVectorType get: vectorType elementType elements: halfVectorSize.
	
	leftIndices := (0 to: halfVectorSize - 1) collect: [ :i | i*2 ].
	rightIndices := (0 to: halfVectorSize - 1) collect: [ :i | i*2 + 1 ].
	
	leftVector := self vector: firstShuffleVector shuffleWith: secondShuffleVector mask: leftIndices.

	rightVector := self vector: firstShuffleVector shuffleWith: secondShuffleVector mask: rightIndices.
	
	result := self generateScalarVectorBinaryOperation: operation resultType: halfVectorType left: leftVector right: rightVector name: nil.
	
	^ self generateVectorFold: result with: operation
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

	result := resultLLVMType zeroConstant.
	1 to: resultType elements do: [ :i |
		column := self aggregate: matrix extractValueAt: i - 1.
			
		resultElement := self generateDot: vector with: column mul: multiplyOperation add: additionOperation.
		result := self vector: result insertElement: resultElement at: i - 1.
	].

	^ result
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> initialize [
	super initialize.
	valueDictionary := IdentityDictionary new.
	usedNames := Set new.
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> intToPointerCast: source target: targetType name: name [
	^ self addInstruction: (LLVMIntToPtrInst new
			type: targetType;
			name: name;
			source: source;
			yourself)
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

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> nullVoidPointer [
	^ LLVMConstantPointerNull new type: (self translateType: (target pointerTo: target void))
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> pointerToIntCast: source target: targetType name: name [
	^ self addInstruction: (LLVMPtrToIntInst new
			type: targetType;
			name: name;
			source: source;
			yourself)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> signExtend: source target: targetType name: name [
	^ self addInstruction: (LLVMSExtInst new
			type: targetType;
			name: name;
			source: source;
			yourself)
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
		currentBlockBuilder := bb newReplacer.
		currentBlockBuilder replaceWith: [ :instruction | self translateProxyInstruction: instruction ]
	]
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> translateConstantDynamicLiteral: aConstantLiteral [
	| constantValue |
	self flag: 'TODO: Support the compiled method meta object data.'.
	constantValue := moduleTranslator translateDynamicLiteral: aConstantLiteral value.
	^ LLVMBitCastConstantExpr new
		type: (self translateType: aConstantLiteral type);
		source: constantValue;
		yourself
	"^ LLVMConstantPointerNull new type: (self translateType: aConstantLiteral type)"
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
	aValue isConstantDynamicLiteral ifTrue: [ ^ self translateConstantDynamicLiteral: aValue ].
	^ moduleTranslator translateValue: aValue
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> truncate: source target: targetType name: name [
	^ self addInstruction: (LLVMTruncInst new
			type: targetType;
			name: name;
			source: source;
			yourself)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> vector: sourceVector extractElementAt: sourceIndex [
	^ self addInstruction: (LLVMExtractElementInst new
		type: sourceVector type elementType;
		vector: sourceVector;
		index: (self context int32Ty constant: sourceIndex);
		yourself)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> vector: sourceVector insertElement: element at: destIndex [
	^ self addInstruction: (LLVMInsertElementInst new
		type: sourceVector type;
		vector: sourceVector;
		element: element;
		elementIndex: (self context int32Ty constant: destIndex);
		yourself)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> vector: firstVector shuffleWith: secondVector mask: shufleMask [
	| vectorSize vectorType maskValueType maskType mask |
	vectorSize := shufleMask size.
	vectorType := (LLVMVectorType get: firstVector type elementType elements: vectorSize).
	maskValueType := self context int32Ty.
	maskType := (LLVMVectorType get: maskValueType elements: vectorSize).
	mask := maskType constant: (shufleMask collect: [:maskElement | self context int32Ty constant: maskElement]).
	
	^ self addInstruction: (LLVMShuffleVectorInst new
		type: vectorType;
		firstVector: firstVector;
		secondVector: secondVector;
		mask: mask;
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitAlloca: instruction [
	| valueType resultType |
	valueType := self translateType: instruction valueType.
	resultType := self translateType: instruction type.
	^ self addInstruction: (LLVMAllocaInst new
		name: (self convertName: instruction name);
		type: resultType;
		valueType: valueType;
		alignment: instruction valueType alignment;
		yourself)
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
SLVMLLVMFunctionCodeGenerator >> visitBitCast: instruction [
	^ self bitCast: (self translateValue: instruction source)
		target: (self translateType: instruction type)
		name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitBranch: instruction [
	^ self addInstruction: (LLVMBranchInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		condition: (self translateValue: instruction condition);
		trueDestination: (self translateValue: instruction trueBlock);
		falseDestination: (self translateValue: instruction falseBlock);
		yourself)
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
	^ self call: calledFunction arguments: arguments returnType: type name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDebugInstructionDeclareVariable: instruction [
	| debugDeclareIntrinsic address localVariable expression |
	debugDeclareIntrinsic := moduleTranslator llvmModule getDebugDeclareIntrinsic.

	address := (self translateValue: instruction variable) asLLVMMetadata asLLVMValueFor: self context.
	localVariable := (self convertDebugVariable: instruction debugInformation) asLLVMValueFor: self context.
	expression := moduleTranslator emptyDebugExpression asLLVMValueFor: self context.

	^ self addInstruction: (LLVMCallInst new
		name: (self convertName: instruction name);
		calledFunction: debugDeclareIntrinsic;
		arguments: {address . localVariable . expression };
		type: debugDeclareIntrinsic returnType;
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDebugInstructionSetVariableValue: instruction [
	| debugValueIntrinsic localVariable expression newValue offset |
	debugValueIntrinsic := moduleTranslator llvmModule getDebugValueIntrinsic.
	newValue := (self translateValue: instruction value) asLLVMMetadata asLLVMValueFor: self context.
	offset := self context int64Ty constant: 0.

	localVariable := (self convertDebugVariable: instruction variable) asLLVMValueFor: self context.
	expression := moduleTranslator emptyDebugExpression asLLVMValueFor: self context.
	
	^ self addInstruction: (LLVMCallInst new
		name: (self convertName: instruction name);
		calledFunction: debugValueIntrinsic;
		arguments: {newValue . offset . localVariable . expression };
		type: debugValueIntrinsic returnType;
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitExtractValue: instruction [
	^ self addInstruction: (LLVMExtractValueInst new
		name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		aggregate: (self translateValue: instruction aggregate);
		indices: instruction indices;
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitExtractVectorElement: instruction [
	^ self addInstruction: (LLVMExtractElementInst new
		name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		vector: (self translateValue: instruction vector);
		index: (self translateValue: instruction index);
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitFloatingPointCast: instruction [
	instruction source type size < instruction type size ifTrue: [ 
		^ self addInstruction: (LLVMFPExtInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself)
	].
	^ self addInstruction: (LLVMFPTruncInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself)

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitGetElementPointer: instruction [
	^ self addInstruction: (LLVMGetElementPtrInst new
		type: (self translateType: instruction type);
		name: (self convertName: instruction name);
		pointer: (self translateValue: instruction pointer);
		indices: (instruction indices collect: [ :index | self translateValue: index ]);
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitIntToFloatCast: instruction [
	instruction source type isSigned ifTrue: [ 
		^ self addInstruction: (LLVMSIToFPInst new
				type: (self translateType: instruction type);
				name: (self convertName: instruction name);
				source: (self translateValue: instruction source);
				yourself)
	].
	^ self addInstruction: (LLVMUIToFPInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself)

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitIntToPointerCast: instruction [
	^ self intToPointerCast: (self translateValue: instruction source)
		target: (self translateType: instruction type)
		name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitJump: instruction [
	| destination |
	destination := self translateValue: instruction destination.
	^ self addInstruction: (LLVMBranchInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		trueDestination: destination;
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitLoad: instruction [
	| pointer type |
	type := self translateType: instruction type.
	pointer := self translateValue: instruction variable.
	^ self addInstruction: (LLVMLoadInst new
		name: (self convertName: instruction name);
		volatile: instruction volatile;
		pointer: pointer;
		type: type;
		yourself)
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
SLVMLLVMFunctionCodeGenerator >> visitMessageSend: instruction [
	| returnType receiver arguments selector lookupResult calledFunctionType calledType functionPointer |
	instruction isSuperSend ifTrue: [ ^ self generateSuperMessageSend: instruction ].

	returnType := self translateType: instruction type.	
	receiver := self translateValue: instruction receiver.
	arguments := instruction arguments collect: [ :arg | self translateValue: arg ].
	selector := self translateValue: instruction selector.
	
	"Lookup the message"
	lookupResult := self callRuntimeFunction: target objectModel messageLookupFunction
		arguments: { receiver . selector . self doesNotUnderstandTrampolineFor: instruction }
		type: [ self halt ]
		name: (self convertName: instruction name).
	self convertDebugLocationFrom: instruction into: lookupResult.
	
	"Cast the found message"
	self flag: 'TODO: Support the smalltalk calling conventions'.
	calledFunctionType := SLVMFunctionType callingConvention: SLVMFunctionType stdcallCallingConvention arguments: {instruction receiver type} , (instruction arguments collect: #type) returnType: instruction type.
	calledType := self translateType: (target pointerTo: calledFunctionType).

	functionPointer := self bitCast: lookupResult target: calledType name: nil.
	^ self call: functionPointer
		convention: (self convertCallingConvention: calledFunctionType callingConvention)
		arguments: {receiver}, arguments returnType: returnType name: nil.
	
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitPhi: instruction [
	| result |
	result := self addInstruction: (LLVMPHINode new
			name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		yourself).
	instruction valuesAndParentsDo: [ :value :parent |
		result addValue: (self translateValue: value) incomingFrom: (self translateValue: parent)
	].

	^ result
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitPointerToIntCast: instruction [
	^ self pointerToIntCast: (self translateValue: instruction source)
		target: (self translateType: instruction type)
		name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitReturn: instruction [
	^ self addInstruction: (LLVMReturnInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		value: (self translateValue: instruction value);
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitReturnVoid: instruction [
	^ self addInstruction: (LLVMReturnInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitSignExtend: instruction [
	^ self signExtend: (self translateValue: instruction source)
		target: (self translateType: instruction type)
		name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitStore: instruction [
	| pointer value |
	pointer := self translateValue: instruction variable.
	value := self translateValue: instruction value.
	^ self addInstruction: (LLVMStoreInst new
		name: (self convertName: instruction name);
		volatile: instruction volatile;
		pointer: pointer;
		value: value;
		type: self context voidTy;
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitTruncate: instruction [
	^ self truncate: (self translateValue: instruction source)
		target: (self translateType: instruction type)
		name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryFloatNegation: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	self assert: resultType isFloatingPointTy.
	^ self addInstruction: (LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #fsub;
			type: resultType;
			left: resultType zeroConstant;
			right: (self translateValue: instruction operand);
			yourself)
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
	^ self addInstruction: (LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #sub;
			type: resultType;
			left: resultType zeroConstant;
			right: (self translateValue: instruction operand);
			yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryNot: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	self assert: resultType isIntegerTy.
	^ self addInstruction: (LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #xor;
			type: resultType;
			left: resultType allOnesConstant;
			right: (self translateValue: instruction operand);
			yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryOperation: instruction [
	^ self perform: (UnaryOperationMap at: instruction operation) with: instruction

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnarySqrt: instruction [
	self halt

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitZeroExtend: instruction [
	^ self zeroExtend: (self translateValue: instruction source)
		target: (self translateType: instruction type)
		name: (self convertName: instruction name)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> zeroExtend: source target: targetType name: name [
	^ self addInstruction: (LLVMZExtInst new
			type: targetType;
			name: name;
			source: source;
			yourself)
]
