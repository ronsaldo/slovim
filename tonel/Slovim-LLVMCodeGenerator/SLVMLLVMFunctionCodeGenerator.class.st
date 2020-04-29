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
		'currentBlockBuilder',
		'currentUnwindBlock',
		'thisContextLocalVariable'
	],
	#classVars : [
		'BinaryFloatComparisonOperationMap',
		'BinaryIntegerComparisonOperationMap',
		'BinaryOperationMap',
		'MemoryOrderingDictionary',
		'UnaryOperationMap'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #initialization }
SLVMLLVMFunctionCodeGenerator class >> initialize [
	MemoryOrderingDictionary := Dictionary newFromPairs: #(
		"Relaxed" 0 monotonic
		"Consume" 1 acquire
		"Acquire" 2 acquire
		"Release" 3 release
		"AcquireAndRelease" 4 acq_rel
		"SequentiallyConsistent" 5 seq_cst
	).
	
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
		ufle ule
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
SLVMLLVMFunctionCodeGenerator >> binaryOperation: operation left: left right: right name: name [
	^ self addInstruction: (LLVMBinaryOperator new
		name: name;
		type: left type;
		operation: operation;
		left: left;
		right: right;
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
	| invokeInstruction |
	(self shouldUseInvokeForCalling: calledFunction) ifTrue: [
		invokeInstruction := self addInstruction: (LLVMInvokeInst new
			name: name;
			calledFunction: calledFunction;
			arguments: arguments;
			type: returnType;
			callingConvention: callingConvention;
			unwindDestination: currentUnwindBlock;
			yourself).
		invokeInstruction normalDestination: currentBlockBuilder newBasicBlock.
		^ invokeInstruction
	].

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
	^ self callRuntimeFunction: runtimeFunctionOrSymbol arguments: arguments type: typeDefinition name: nil
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
SLVMLLVMFunctionCodeGenerator >> callScalarMathDoubleFunction: standardFunctionName arguments: arguments resultType: expectedResultType name: name [
	| doubleTy standardFunction vectorSize operationResultType result elementArguments resultElement convertedArguments |
	doubleTy := self context doubleTy.
	standardFunction := self llvmModule getIntrinsic: standardFunctionName orCreateWithType: [
		LLVMFunctionType get: doubleTy params: (arguments collect: [:a | doubleTy]) isVarArg: false
	].
	vectorSize := 1.
	arguments do: [ :arg |
		arg type isVectorTy ifTrue: [
			vectorSize > 1 ifTrue: [ 
				self assert: arg type elements = vectorSize
			] ifFalse: [ 
				vectorSize := arg type elements
			]
		]
	].

	vectorSize = 1 ifTrue: [
		convertedArguments := arguments collect: [ :arg |
			self assert: arg type isFloatingPointTy.
			arg type = doubleTy ifTrue: [ 
				arg
			] ifFalse: [ 
				self castFloat: arg into: doubleTy name: nil
			]
		].

		result := self call: standardFunction arguments: convertedArguments returnType: doubleTy name: name.
	] ifFalse: [
		operationResultType := LLVMVectorType get: doubleTy elements: vectorSize.
		
		convertedArguments := arguments collect: [ :arg |
			arg type isVectorTy ifTrue: [ 
				self assert: arg type elementType isFloatingPointTy.
				arg type ~= operationResultType ifTrue: [ 
					self castFloat: arg into: operationResultType name: nil
				] ifFalse: [
					arg
				]
			] ifFalse: [ 
				self assert: arg type isFloatingPointTy.
				arg type ~= doubleTy ifTrue: [ 
					self castFloat: arg into: operationResultType name: nil
				] ifFalse: [ 
					arg
				].
			]
		].
	
		result := operationResultType zeroConstant.
		0 to: vectorSize - 1 do: [ :i |
			elementArguments := convertedArguments collect: [ :arg |
				arg type isVectorTy ifTrue: [ 
					self vector: arg extractElementAt: i
				] ifFalse: [
					arg
				]
			].
			resultElement := self call: standardFunction arguments: elementArguments returnType: doubleTy name: nil.
			result := self vector: result insertElement: resultElement at: i
		]
	].

	result type ~= expectedResultType ifTrue: [
		self assert: (expectedResultType isFloatingPointTy or: [expectedResultType isVectorTy and: [expectedResultType elementType isFloatingPointTy]]).
		^ self castFloat: result into: expectedResultType name: nil
	].

	^ result
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> castFloat: floatValue into: targetType name: name [
	floatValue type bits < targetType bits ifTrue: [
		^ self addInstruction: (LLVMFPExtInst new
			type: targetType;
			name: name;
			source: floatValue;
			yourself)
	].
	^ self addInstruction: (LLVMFPTruncInst new
			type: targetType;
			name: name;
			source: floatValue;
			yourself)

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

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> clampVectorOrScalar: vectorOrScalarValue minValue: minConstantValue maxValue: maxConstantValue [
	| resultType int1Ty comparisonType clamped comparisonResult |
	resultType := vectorOrScalarValue type.
	int1Ty := self context int1Ty.
	comparisonType := resultType isVectorTy
		ifTrue: [ LLVMVectorType get: int1Ty elements: resultType elements  ]
		ifFalse: [ int1Ty ].

	clamped := vectorOrScalarValue.
	comparisonResult := self fcmp: #ule left: clamped right: maxConstantValue type: comparisonType name: nil.
	clamped := self select: comparisonResult trueValue: clamped falseValue: maxConstantValue name: nil.
	
	comparisonResult := self fcmp: #uge left: minConstantValue right: clamped type: comparisonType name: nil.
	clamped := self select: comparisonResult trueValue: minConstantValue falseValue: clamped name: nil.
	
	^ clamped

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
	^ moduleTranslator convertDebugScope: debugScope fallbackTo: functionDebugScope
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> convertDebugSourceLocation: debugSourceLocation debugInformation: debugInformation [
	| debugScope |
	debugSourceLocation ifNil: [ ^ nil ].
	debugScope := self convertDebugScope: (debugInformation ifNil: [ debugSourceLocation scope ] ifNotNil: #scope).
	
	^ moduleTranslator convertDebugSourceLocation: debugSourceLocation withScope: debugScope
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> convertDebugVariable: debugInformation [
	^ moduleTranslator convertDebugVariable: debugInformation fallbackScopeInto: functionDebugScope
]

{ #category : #'atomic intrinsics' }
SLVMLLVMFunctionCodeGenerator >> convertMemoryOrdering: ordering [
	ordering isSymbol ifTrue: [ ^ ordering ].
	(ordering isNil or: [ ordering isConstantValue not ]) ifTrue: [ ^ #seq_cst ].
	^ MemoryOrderingDictionary at: ordering value
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

	function basicBlocks do: [ :bb |
		bb unwindBlock ifNotNil: [ :unwindBlock |
			(self translateValue: bb)
				implicitUnwindBlock: (self translateValue: unwindBlock)
		].
	]
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> createSpillingAlloca: valueType [
	| allocaInstruction |
	allocaInstruction := LLVMAllocaInst new
		valueType: valueType;
		type: (LLVMPointerType getUnqual: valueType);
		yourself.
	llvmFunction basicBlocks first == currentBlockBuilder block ifTrue: [ 
		currentBlockBuilder insertAllocaInstruction: allocaInstruction
	] ifFalse: [ 
		llvmFunction basicBlocks first insertAllocaInstruction: allocaInstruction
	].
	^ allocaInstruction
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> doesNotUnderstandTrampolineFor: instruction [
	instruction isDoesNotUnderstandMessage ifTrue: [ 
		^ self nullVoidPointer
	].
	
	^ moduleTranslator doesNotUnderstandTrampolineWithType: instruction doesNotUnderstandTrampolineFunctionType
]

{ #category : #'vector intrinsics' }
SLVMLLVMFunctionCodeGenerator >> expandScalar: scalar toVectorType: vectorType [
	| vectorConstant |
	vectorConstant := vectorType zeroConstant.
	vectorConstant := self vector: vectorConstant insertElement: scalar at: 0.
	^ self vector: vectorConstant shuffleWith: vectorConstant mask: ((Array new: vectorType elements) atAllPut: 0)
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

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> fcmp: operation left: left right: right type: resultType name: name [
	^ self addInstruction: (LLVMFCmpInst new
			name: name;
			operation: operation;
			type: resultType;
			left: left;
			right: right;
			yourself)
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> fp: sourceValue toSI: targetType name: name [
	^self addInstruction: (LLVMFPToSIInst new
		type: targetType;
		name: name;
		source: sourceValue;
		yourself)
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> fp: sourceValue toUI: targetType name: name [
	^ self addInstruction: (LLVMFPToUIInst new
		type: targetType;
		name: name;
		source: sourceValue;
		yourself)
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
SLVMLLVMFunctionCodeGenerator >> generateAtomicCompare: sourcePointer with: comparisonValue andSwapWith: newValue ordering: memoryOrdering returnType: returnType [
	| cmpxchg |
	cmpxchg := self compare: (self translateValue: sourcePointer)
		with: (self translateValue: comparisonValue)
		andSwapWith: (self translateValue: newValue).
	cmpxchg ordering: (self convertMemoryOrdering: memoryOrdering).
		
	^ returnType isBooleanType ifTrue: [
		self aggregate: cmpxchg extractValueAt: 1
	] ifFalse: [
		self aggregate: cmpxchg extractValueAt: 0
	].

]

{ #category : #'atomic intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateAtomicLoad: sourcePointer returnType: returnType ordering: memoryOrdering [ 
	| loadResult |
	loadResult := self addInstruction: (LLVMLoadInst new
		type: (self translateType: sourcePointer type baseType);
		pointer: (self translateValue: sourcePointer);
		atomic: true;
		ordering: (self convertMemoryOrdering: memoryOrdering);
		align: sourcePointer type baseType alignment;
		yourself).
	returnType isBooleanType ifTrue: [
		^ self truncate: loadResult target: (self translateType: returnType) name: nil
	].
		
	^ loadResult
]

{ #category : #'atomic intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateAtomicRMW: sourcePointer with: operandValue operation: operation ordering: memoryOrdering returnType: returnType [
	| result operand operationType |
	operand := self translateValue: operandValue.
	operationType := self translateType: sourcePointer type baseType.
	operandValue type isBooleanType ifTrue: [ 
		operand := self zeroExtend: operand target: operationType name: nil
	].

	result := self addInstruction: (LLVMAtomicRMWInst new
		operation: operation;
		type: operationType;
		pointer: (self translateValue: sourcePointer);
		operand: operand;
		ordering: (self convertMemoryOrdering: memoryOrdering);
		yourself).
	returnType isBooleanType ifTrue: [
		^ self truncate: result target: (self translateType: returnType) name: nil
	].

	^ result
]

{ #category : #'atomic intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateAtomicStoreIn: pointer value: value ordering: memoryOrdering [
	| storedValue |
	storedValue := (self translateValue: value).
	value type isBooleanType ifTrue: [
		storedValue := self zeroExtend: storedValue target: (self translateType: pointer type baseType) name: nil
	].
	
	^ self addInstruction: (LLVMStoreInst new
		type: self context voidTy;
		pointer: (self translateValue: pointer);
		value: storedValue;
		atomic: true;
		ordering: (self convertMemoryOrdering: memoryOrdering);
		align: pointer type baseType alignment;
		yourself)
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> generateBuiltInCall: callInstruction byCallingScalarMathDoubleFunction: standardFunctionName [
	| arguments |
	arguments := callInstruction arguments collect: [:arg | self translateValue: arg].
	^ self callScalarMathDoubleFunction: standardFunctionName arguments: arguments
		resultType: (self translateType: callInstruction type)
		name: (self convertName: callInstruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> generateBuiltInFunction: builtInFunction call: instruction [
	| generator |
	generator := SLVMLLVMBuiltInFunctionGenerator fromName: builtInFunction name.
	generator ifNil: [ self error: 'Failed to generate built-in function.' ].
	
	^ generator generateWith: self builtInFunction: builtInFunction callInstruction: instruction
]

{ #category : #'linear algebra' }
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
	
	function returnType isIntegerType ifTrue: [ 
		function returnType isSigned ifTrue: [ 
			llvmFunction addReturnAttribute: #signext
		] ifFalse: [ 
			llvmFunction addReturnAttribute: #zeroext
		]
	].

	self
		mapArguments;
		createProxyValues;
		translateBasicBlocks

]

{ #category : #'linear algebra' }
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

{ #category : #'linear algebra' }
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

{ #category : #'linear algebra' }
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

{ #category : #'linear algebra' }
SLVMLLVMFunctionCodeGenerator >> generateMatrixTimesVector: instruction [
"
void matrixMultiply(float matrix[4][4], float vector[4], float result[4])
	for(int k = 0; k < 4; ++k) // Add columns
		for(int i = 0; i < 4; ++i)
			result[i] += matrix[i][k]*vector[k]
"
	| multiplyOperation additionOperation matrixType vectorType resultType matrix vector result multiply resultLLVMType column rows vectorElement |
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
	rows := matrixType rows.

	vectorElement := self vector: vector shuffleWith: vector mask: ((0 to: rows - 1) collect: [ :mi | 0 ]).
	result := self generateScalarVectorBinaryOperation: multiplyOperation
		resultType: resultLLVMType
		left: column
		right: vectorElement name: nil.
		
	2 to: matrixType columns do: [ :i |
		column := self aggregate: matrix extractValueAt: i - 1.
		vectorElement := self vector: vector shuffleWith: vector mask: ((0 to: rows - 1) collect: [ :mi | i - 1 ]).
		multiply := self generateScalarVectorBinaryOperation: multiplyOperation
			resultType: resultLLVMType
			left: column
			right: vectorElement name: nil.

		result := self generateScalarVectorBinaryOperation: additionOperation
			resultType: resultLLVMType
			left: result
			right: multiply name: nil.
	].

	^ result

]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateMinMaxWithComparison: comparison of: left with: right [
	| leftOperand rightOperand resultType int1Ty comparisonType scalarType comparisonResult |
	leftOperand := self translateValue: left.
	rightOperand := self translateValue: right.
	self assert: leftOperand type = rightOperand type.
	
	resultType := leftOperand type.
	int1Ty := self context int1Ty.
	comparisonType := resultType isVectorTy
		ifTrue: [ LLVMVectorType get: int1Ty elements: resultType elements  ]
		ifFalse: [ int1Ty ].
	scalarType := resultType isVectorTy
		ifTrue: [ resultType elementType  ]
		ifFalse: [ resultType ].
		
	comparisonResult := scalarType isFloatingPointTy
		ifTrue: [ self fcmp: comparison left: leftOperand right: rightOperand type: comparisonType name: nil ]
		ifFalse: [ self icmp: comparison left: leftOperand right: rightOperand type: comparisonType name: nil ].
		
	^ self select: comparisonResult trueValue: leftOperand falseValue: rightOperand name: nil
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateMixFrom: fromPoint to: endPoint at: alpha [
	| fromPointValue endPointValue alphaValue resultType oneMinusAlpha fromContribution endContribution |
	fromPointValue := self translateValue: fromPoint.
	endPointValue := self translateValue: endPoint.
	self assert: fromPointValue type = endPointValue type.
	alphaValue := self translateValue: alpha.
	
	resultType := fromPointValue type.
	
	fromPointValue type isVectorTy ifTrue: [ 
		alphaValue type isVectorTy ifTrue: [ 
			self assert: fromPointValue type = alphaValue type.
		] ifFalse: [
			self expandScalar: alphaValue toVectorType: resultType
		]
	].

	oneMinusAlpha := self binaryOperation: #fsub left: resultType oneConstant right: alphaValue name: nil.
	fromContribution := self binaryOperation: #fmul left: fromPointValue right: oneMinusAlpha name: nil.
	endContribution := self binaryOperation: #fmul left: endPointValue right: alphaValue name: nil.
	^ self binaryOperation: #fadd left: fromContribution right: endContribution name: nil.
]

{ #category : #'linear algebra' }
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
		^ self icmp: mappedOperation left: left right: right type: resultType name: name
	].

	BinaryFloatComparisonOperationMap at: operation ifPresent: [ :mappedOperation |
		^ self fcmp: mappedOperation left: left right: right type: resultType name: name
	].

	self error: 'Unsupported binary operation.'

]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateSmoothStepEdge: leftEdge edge: rightEdge value: argument [
	| leftEdgeValue rightEdgeValue argumentValue resultType t deltaEdge tsquare t2 constantThree threeMinus2T |
	leftEdgeValue := self translateValue: leftEdge.
	rightEdgeValue := self translateValue: rightEdge.
	argumentValue := self translateValue: argument.
	
	resultType := argumentValue type.
	resultType isVectorTy ifTrue: [ 
		leftEdgeValue type isVectorTy ifFalse: [ 
			leftEdgeValue := self expandScalar: leftEdgeValue toVectorType: resultType
		].
		rightEdgeValue type isVectorTy ifFalse: [ 
			rightEdgeValue := self expandScalar: rightEdgeValue toVectorType: resultType
		].
	].

	"Compute t"
	t := self binaryOperation: #fsub left: argumentValue right: leftEdgeValue name: nil.
	deltaEdge := self binaryOperation: #fsub left: rightEdgeValue right: leftEdgeValue name: nil.
	t := self binaryOperation: #fdiv left: t right: deltaEdge name: nil.
	
	"Clamp t."
	t := self clampVectorOrScalar: t minValue: resultType zeroConstant maxValue: resultType oneConstant.

	"Hermite polynomial evaluation."
	tsquare := self binaryOperation: #fmul left: t right: t name: nil.
	t2 := self binaryOperation: #fadd left: t right: t name: nil.
	constantThree := resultType constantScalarValue: 3.0.
	threeMinus2T := self binaryOperation: #fsub left: constantThree right: t2 name: nil.
	
	^ self binaryOperation: #fmul left: tsquare right: threeMinus2T name: nil.
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateStepEdge: edge value: argument [
	| edgeValue argumentValue resultType int1Ty comparisonType comparisonResult |
	edgeValue := self translateValue: edge.
	argumentValue := self translateValue: argument.
	
	resultType := argumentValue type.
	resultType isVectorTy ifTrue: [ 
		edgeValue type isVectorTy ifFalse: [ 
			edgeValue := self expandScalar: edgeValue toVectorType: resultType
		].
	].

	int1Ty := self context int1Ty.
	comparisonType := resultType isVectorTy
		ifTrue: [ LLVMVectorType get: int1Ty elements: resultType elements  ]
		ifFalse: [ int1Ty ].

	comparisonResult := self fcmp: #ult left: argumentValue right: edgeValue  type: comparisonType name: nil.
	^ self select: comparisonResult trueValue: resultType zeroConstant falseValue: resultType oneConstant name: nil
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

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> generateVector: vector packMinValue: minValue maxValue: maxValue channels: channelCount channelSize: channelBitSize channelScale: channelScale returnType: returnType [
	| vectorValue vectorType minConstantValue maxConstantValue clampedVector channelScaleConstant scaledVector halfIntegerConstant biasedVector channelIntegerType packedVectorType packedVector |
	vectorValue := self translateValue: vector.
	vectorType := vectorValue type.
	minConstantValue := vectorType constantScalarValue: minValue.
	maxConstantValue := vectorType constantScalarValue: maxValue.
	channelIntegerType := nil.
	channelBitSize = 8 ifTrue: [ channelIntegerType := self context int8Ty ].
	channelBitSize = 16 ifTrue: [ channelIntegerType := self context int16Ty ].
	channelBitSize = 32 ifTrue: [ channelIntegerType := self context int32Ty ].
	self assert: channelIntegerType isNotNil.
	packedVectorType := LLVMVectorType get: channelIntegerType elements: channelCount.
	
	clampedVector := self clampVectorOrScalar: vectorValue minValue: minConstantValue maxValue: maxConstantValue.
	
	channelScaleConstant := vectorType constantScalarValue: channelScale.
	scaledVector := self binaryOperation: #fmul left: clampedVector right: channelScaleConstant name: nil.
	halfIntegerConstant := vectorType constantScalarValue: 0.5.
	biasedVector := self binaryOperation: #fadd left: scaledVector right: halfIntegerConstant name: nil.
	
	packedVector := minValue < 0
		ifTrue: [ self fp: biasedVector toSI: packedVectorType name: nil ]
		ifFalse: [ self fp: biasedVector toUI: packedVectorType name: nil ].
	^ self bitCast: packedVector target: returnType name: nil
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> generateVector: packedVectorInteger signed: isSigned unpackScale: unpackScale channels: channelCount channelSize: channelBitSize returnType: vectorType [
	| packedVectorIntegerValue channelIntegerType packedVectorType packedVector normalizedVector unpackScaleConstant unpackedVector |
	packedVectorIntegerValue := self translateValue: packedVectorInteger.

	channelIntegerType := nil.
	channelBitSize = 8 ifTrue: [ channelIntegerType := self context int8Ty ].
	channelBitSize = 16 ifTrue: [ channelIntegerType := self context int16Ty ].
	channelBitSize = 32 ifTrue: [ channelIntegerType := self context int32Ty ].
	self assert: channelIntegerType isNotNil.
	packedVectorType := LLVMVectorType get: channelIntegerType elements: channelCount.
	packedVector := self bitCast: packedVectorIntegerValue target: packedVectorType name: nil.
	
	normalizedVector := isSigned
		ifTrue: [ self si: packedVector toFP: vectorType name: nil ]
		ifFalse: [ self ui: packedVector toFP: vectorType name: nil ].
	unpackScaleConstant := vectorType constantScalarValue: unpackScale.
	unpackedVector := self binaryOperation: #fdiv left: normalizedVector right: unpackScaleConstant name: nil.
	
	isSigned ifTrue: [
		unpackedVector := self clampVectorOrScalar: unpackedVector 
			minValue: (vectorType constantScalarValue: -1.0)
			maxValue: (vectorType constantScalarValue: 1.0)
	].
	
	^ unpackedVector
]

{ #category : #'vector intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateVectorAll: vector [
	^ self generateVectorFold: (self translateValue: vector) with: #bitand
]

{ #category : #'vector intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateVectorAny: vector [
	^ self generateVectorFold: (self translateValue: vector) with: #bitor
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

{ #category : #'linear algebra' }
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

{ #category : #'vector intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateVectorLength: vector [
	| vectorValue length2 intrinsic |
	vectorValue := self translateValue: vector.
	length2 := self generateDot: vectorValue with: vectorValue mul: #fmul add: #fadd.
	intrinsic := self getOverloadedIntrinsic: 'llvm.sqrt' argumentTypes: {length2 type} returnType: length2 type.
	^ self call: intrinsic arguments: { length2 } returnType: length2 type name: nil
]

{ #category : #'vector intrinsics' }
SLVMLLVMFunctionCodeGenerator >> generateVectorNormalize: vector [
	| vectorValue length2 intrinsic length lengthVector |
	vectorValue := self translateValue: vector.
	length2 := self generateDot: vectorValue with: vectorValue mul: #fmul add: #fadd.
	intrinsic := self getOverloadedIntrinsic: 'llvm.sqrt' argumentTypes: {length2 type} returnType: length2 type.
	length := self call: intrinsic arguments: { length2 } returnType: length2 type name: nil.
	
	lengthVector := LLVMConstantZeroInitializer new type: vectorValue type.
	lengthVector := self vector: lengthVector insertElement: length at: 0.
	lengthVector := self vector: lengthVector shuffleWith: lengthVector mask: ((Array new: vectorValue type elements) atAllPut: 0).
	^ self binaryOperation: #fdiv left: vectorValue right: lengthVector name: nil
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateVectorOrScalar: vectorOrScalar constantMultiplication: constantValue [
	| vectorOrScalarValue constant |
	vectorOrScalarValue := self translateValue: vectorOrScalar.
	constant := vectorOrScalarValue type constantScalarValue: constantValue.
	^ self binaryOperation: #fmul left: vectorOrScalarValue right: constant name: nil
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateVectorOrScalarAbsoluteValue: vectorOrScalar [
	| vectorOrScalarValue zeroConstant resultType int1Ty comparisonType scalarType negatedVector isPositive |
	vectorOrScalarValue := self translateValue: vectorOrScalar.
	resultType := vectorOrScalarValue type.
	int1Ty := self context int1Ty.
	scalarType := resultType isVectorTy
		ifTrue: [ resultType elementType ]
		ifFalse: [ resultType ].
	comparisonType := resultType isVectorTy
		ifTrue: [ LLVMVectorType get: int1Ty elements: resultType elements ]
		ifFalse: [ int1Ty ].

	zeroConstant := vectorOrScalarValue type zeroConstant.

	negatedVector := scalarType isFloatingPointTy
		ifTrue: [ self binaryOperation: #fsub left: zeroConstant right: vectorOrScalarValue name: nil]
		ifFalse: [self binaryOperation: #sub left: zeroConstant right: vectorOrScalarValue name: nil].

	isPositive := scalarType isFloatingPointTy
		ifTrue: [self fcmp: #uge left: vectorOrScalarValue right: zeroConstant type: comparisonType name: nil]
		ifFalse: [self icmp: #sge left: vectorOrScalarValue right: zeroConstant type: comparisonType name: nil].
	^ self select: isPositive trueValue: vectorOrScalarValue falseValue: negatedVector name: nil
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateVectorOrScalarFloorFract: vectorOrScalar [
	| vectorOrScalarValue resultType  floorFunction floorValue |
	vectorOrScalarValue := self translateValue: vectorOrScalar.
	resultType := vectorOrScalarValue type.
	floorFunction := self getOverloadedIntrinsic: 'llvm.floor' argumentTypes: {resultType} returnType: resultType.
	floorValue := self call: floorFunction arguments: { vectorOrScalarValue } returnType: resultType name: nil.
	^ self binaryOperation: #fsub left: vectorOrScalarValue right: floorValue name: nil
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateVectorOrScalarFloorMod: dividend divisor: divisor [
	| resultType  floorFunction dividendValue divisorValue divisionValue divisionFloorValue wholeDivisions |
	dividendValue := self translateValue: dividend.
	divisorValue := self translateValue: divisor.
	resultType := dividendValue type.
	divisionValue := self binaryOperation: #fdiv left: dividendValue right: divisorValue name: nil.
	
	floorFunction := self getOverloadedIntrinsic: 'llvm.floor' argumentTypes: {resultType} returnType: resultType.
	divisionFloorValue := self call: floorFunction arguments: { divisionValue } returnType: resultType name: nil.
	
	wholeDivisions := self binaryOperation: #fmul left: divisorValue right: divisionFloorValue name: nil.
	^ self binaryOperation: #fsub left: dividendValue right: wholeDivisions name: nil
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> generateVectorOrScalarSign: vectorOrScalar [
	| vectorOrScalarValue zeroConstant oneConstant minusOneConstant resultType int1Ty comparisonType lessThanZero greaterThanZero greaterThanZeroResult scalarType |
	vectorOrScalarValue := self translateValue: vectorOrScalar.
	resultType := vectorOrScalarValue type.
	int1Ty := self context int1Ty.
	scalarType := resultType isVectorTy
		ifTrue: [ resultType elementType ]
		ifFalse: [ resultType ].
	comparisonType := resultType isVectorTy
		ifTrue: [ LLVMVectorType get: int1Ty elements: resultType elements ]
		ifFalse: [ int1Ty ].

	zeroConstant := vectorOrScalarValue type zeroConstant.
	oneConstant := vectorOrScalarValue type oneConstant.
	minusOneConstant := vectorOrScalarValue type minusOneConstant.

	greaterThanZero := scalarType isFloatingPointTy
		ifTrue: [self fcmp: #ugt left: vectorOrScalarValue right: zeroConstant type: comparisonType name: nil]
		ifFalse: [self icmp: #sgt left: vectorOrScalarValue right: zeroConstant type: comparisonType name: nil].
	greaterThanZeroResult := self select: greaterThanZero trueValue: oneConstant falseValue: zeroConstant name: nil.
	
	lessThanZero := scalarType isFloatingPointTy
		ifTrue: [self fcmp: #ult left: vectorOrScalarValue right: zeroConstant type: comparisonType name: nil]
		ifFalse: [self icmp: #slt left: vectorOrScalarValue right: zeroConstant type: comparisonType name: nil].
	^ self select: lessThanZero trueValue: minusOneConstant falseValue: greaterThanZeroResult name: nil
]

{ #category : #'linear algebra' }
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
SLVMLLVMFunctionCodeGenerator >> getOrCreateInlineCacheFor: instruction [
	| inlineCachePointerType |
	inlineCachePointerType := target objectModel messageLookupFunction functionType arguments last.
	^ self translateValue: inlineCachePointerType defaultConstant
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> getOrCreateThisContextLocalVariable [
	^ thisContextLocalVariable ifNil: [thisContextLocalVariable := self createSpillingAlloca: (self context int32Ty)]
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> getOverloadedIntrinsic: intrinsicName argumentTypes: argumentTypes returnType: returnType [
	| fullName |
	fullName := intrinsicName.
	argumentTypes do: [ :type |
		fullName := fullName , '.' , type overloadedIntrinsicName
	].

	^ self llvmModule getIntrinsic: fullName orCreateWithType: [
		LLVMFunctionType get: returnType params: argumentTypes isVarArg: false
	]
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> getReference: reference constElement: constElementIndex [
	| resultType int32Ty |
	self assert: reference type isPointerTy.
	resultType := LLVMPointerType get: (reference type elementType elementAtConstIndex: constElementIndex) addressSpace: reference type addressSpace.
	int32Ty := self context int32Ty.
	
	^ self addInstruction: (LLVMGetElementPtrInst new
		type: resultType;
		pointer: reference;
		indices: { int32Ty constant: 0 . int32Ty constant: constElementIndex}
	)
]

{ #category : #'instruction building' }
SLVMLLVMFunctionCodeGenerator >> icmp: operation left: left right: right type: resultType name: name [
	^ self addInstruction: (LLVMICmpInst new
			name: name;
			operation: operation;
			type: resultType;
			left: left;
			right: right;
			yourself)
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

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> llvmModule [
	^ moduleTranslator llvmModule
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> loadFrom: pointer [
	^ self addInstruction: (LLVMLoadInst new
		pointer: pointer;
		type: pointer type elementType;
		yourself)
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> loadLiteralVariableValue: literalVariable [
	| valueOffset valuePointer |
	self assert: literalVariable type isPointerTy.
	self assert: literalVariable type elementType bits = 8.
	valueOffset := target objectModel associationValueOffset.
	valuePointer := self addInstruction: (LLVMGetElementPtrInst new
		type: literalVariable type;
		pointer: literalVariable;
		indices: { self context int32Ty constant: valueOffset };
		yourself).
	valuePointer := self bitCast: valuePointer target: (LLVMPointerType getUnqual: literalVariable type) name: nil.
	^ self addInstruction: (LLVMLoadInst new
		pointer: valuePointer;
		type: literalVariable type;
		yourself)
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> mapArguments [

	| argumentBaseOffset llvmArgument |
	argumentBaseOffset := 0.
	function arguments doWithIndex: [ :arg :index |
		llvmArgument := llvmFunction arguments at: index + argumentBaseOffset.
		llvmArgument name: (self convertName: arg name).
		arg isStructReturnPointer ifTrue: [ llvmArgument addFlag: #sret; addFlag: #noalias ].
		arg type isIntegerType ifTrue: [ 
			arg type isSigned ifTrue: [
				llvmArgument addFlag: #signext
			] ifFalse: [ 
				llvmArgument addFlag: #zeroext
			]
		].
	
		valueDictionary at: arg put: llvmArgument
	]
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> mapContainerType: containerType index: index [
	containerType isUnionType ifTrue: [
		^ {containerType . SLVMConstant int: 0}
	].
	
	^ {containerType . index}
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
SLVMLLVMFunctionCodeGenerator >> nativeMethodDispatchTrampolineFor: instruction [
	^ moduleTranslator nativeMethodDispatchTrampolineWithType: instruction sendDispatchTrampolineType
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> nullVoidPointer [
	^ LLVMConstantPointerNull new type: (self translateType: (target pointerTo: target void))
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> objectMethodDispatchTrampolineFor: instruction [
	^ moduleTranslator objectMethodDispatchTrampolineForWithType: instruction sendDispatchTrampolineType
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
SLVMLLVMFunctionCodeGenerator >> select: condition trueValue: trueValue falseValue: falseValue name: name [
	self assert: trueValue type = falseValue type.
	^ self addInstruction: (LLVMSelectInst new
			name: name;
			condition: condition;
			type: trueValue type;
			trueValue: trueValue;
			falseValue: falseValue;
			yourself)
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> shouldUseInvokeForCalling: functionValue [
	currentUnwindBlock ifNil: [ ^ false ].
	
	functionValue isFunction ifTrue: [
		functionValue isNoUnwind ifTrue: [ ^ false ].
	].

	^ true
]

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> si: sourceValue toFP: targetType name: name [
	^self addInstruction: (LLVMSIToFPInst new
		type: targetType;
		name: name;
		source: sourceValue;
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

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> store: value in: pointer [
	^ self addInstruction: (LLVMStoreInst new
		pointer: pointer;
		value: value;
		type: self context voidTy;
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
	
	| originalBasicBlocks newBasicBlocks |
	originalBasicBlocks := llvmFunction basicBlocks asArray.
	newBasicBlocks := OrderedCollection new.
	originalBasicBlocks do: [ :bb |
		currentUnwindBlock := bb implicitUnwindBlock.
		bb implicitUnwindBlock: nil.
		
		currentBlockBuilder := bb newReplacer.
		currentBlockBuilder replaceWith: [ :instruction | self translateProxyInstruction: instruction ].
		newBasicBlocks addAll: currentBlockBuilder newBasicBlocks
	].

	llvmFunction basicBlocksReplacedWith: newBasicBlocks
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> translateConstantDynamicLiteral: aConstantLiteral [
	| compiledMethodMetaData literalPointerOffset literalPointer |
	compiledMethodMetaData := self translateValue: function compiledMethodMetaDataValue.
	self assert: compiledMethodMetaData type isPointerTy.
	self assert: compiledMethodMetaData type elementType isIntegerTy.
	self assert: compiledMethodMetaData type elementType bits = 8.
	
	literalPointerOffset := target objectModel compiledMethodMetadataLiteralOffsetWithIndex: aConstantLiteral index.
	literalPointer := LLVMGetElementPtrConstantExpr new
		type: compiledMethodMetaData type;
		inbounds: true;
		pointer: compiledMethodMetaData;
		indices: { self context int32Ty constant: literalPointerOffset };
		yourself.
	literalPointer := LLVMBitCastConstantExpr new
		type: (LLVMPointerType getUnqual: (self translateType: aConstantLiteral type));
		source: literalPointer;
		yourself.
	^ self loadFrom: literalPointer
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
	aValue isFunctionDynamicLiteral ifTrue: [ ^ self translateConstantDynamicLiteral: aValue ].
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

{ #category : #'as yet unclassified' }
SLVMLLVMFunctionCodeGenerator >> ui: sourceValue toFP: targetType name: name [
	^self addInstruction: (LLVMUIToFPInst new
		type: targetType;
		name: name;
		source: sourceValue;
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
SLVMLLVMFunctionCodeGenerator >> visitBoolToDynamicObjectCast: instruction [
	| sourceValue targetType  trueValue falseValue |
	sourceValue := self translateValue: instruction source.
	targetType := self translateType: instruction type.
	
	trueValue := self moduleTranslator translateDynamicLiteral: true.
	trueValue type ~= targetType ifTrue: [ 
		trueValue := LLVMBitCastConstantExpr new type: targetType; source: trueValue; yourself.
	].

	falseValue := self moduleTranslator translateDynamicLiteral: false.
	falseValue type ~= targetType ifTrue: [ 
		falseValue := LLVMBitCastConstantExpr new type: targetType; source: falseValue; yourself.
	].
	^ self select: sourceValue trueValue: trueValue falseValue: falseValue name: (self convertName: instruction name)
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
SLVMLLVMFunctionCodeGenerator >> visitCharToDynamicObjectCast: instruction [
	| sourceType sourceValue targetType conversionFunction conversionResult |
	sourceType := instruction source type.
	sourceValue := self translateValue: instruction source.
	targetType := self translateType: instruction type.

	self assert: sourceType isIntegerType.
	
	"Make sure the source type is at least an Int32"
	sourceType size < 4 ifTrue: [
		sourceType isUnsigned ifTrue: [ 
			sourceValue := self zeroExtend: sourceValue target: self context int32Ty  name: nil
		] ifFalse: [ 
			sourceValue := self signExtend: sourceValue target: self context int32Ty  name: nil
		].
	].

	conversionFunction := target objectModel uint32ToCharacterFunction.
	conversionResult := self callRuntimeFunction: conversionFunction
		arguments: {sourceValue}
		type: [ self halt ]
		name: (self convertName: instruction name).
	self convertDebugLocationFrom: instruction into: conversionResult.
	conversionResult type ~= targetType ifTrue: [
		conversionResult := self bitCast: conversionResult target: targetType name: nil
	].
	
	^ conversionResult
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
SLVMLLVMFunctionCodeGenerator >> visitDynamicObjectToBoolCast: instruction [
	| sourceValue targetType conversionFunction conversionResult targetSLVMType |
	sourceValue := self translateValue: instruction source.
	targetType := self translateType: instruction type.
	targetSLVMType := instruction type.

	self assert: instruction type isBooleanType.

	conversionFunction := target objectModel objectToBoolean8Function.
	conversionResult := self callRuntimeFunction: conversionFunction
		arguments: {sourceValue}
		type: [ self halt ]
		name: (self convertName: instruction name).
	self convertDebugLocationFrom: instruction into: conversionResult.
	self assert: conversionResult type = targetType.

	^ conversionResult
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDynamicObjectToCharCast: instruction [
	^ self visitDynamicObjectToIntCast: instruction
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDynamicObjectToFloatCast: instruction [
	| sourceValue targetType conversionFunction conversionResult targetSLVMType |
	sourceValue := self translateValue: instruction source.
	targetType := self translateType: instruction type.
	targetSLVMType := instruction type.

	self assert: instruction type isFloatType.

	conversionFunction := target objectModel objectToFloat64Function.
	conversionResult := self callRuntimeFunction: conversionFunction
		arguments: {sourceValue}
		type: [ self halt ]
		name: (self convertName: instruction name).
	self convertDebugLocationFrom: instruction into: conversionResult.
	
	"We may need to truncate the result."
	targetSLVMType size < 8 ifTrue: [
		conversionResult := self castFloat: conversionResult into: targetType name: nil
	].

	^ conversionResult
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDynamicObjectToIntCast: instruction [
	| sourceValue targetType conversionFunction conversionResult targetSLVMType |
	sourceValue := self translateValue: instruction source.
	targetType := self translateType: instruction type.
	targetSLVMType := instruction type.

	self assert: instruction type isIntegerType.

	"Select the conversion function"
	conversionFunction := targetSLVMType size <= 4 ifTrue: [
		targetSLVMType isUnsigned ifTrue: [ 
			target objectModel objectToUInt32Function.
		] ifFalse: [ 
			target objectModel objectToInt32Function.
		].
	] ifFalse: [
		self assert: targetSLVMType size = 8.
		targetSLVMType isUnsigned ifTrue: [ 
			target objectModel objectToUInt64Function.
		] ifFalse: [ 
			target objectModel objectToInt64Function.
		].
	].

	conversionResult := self callRuntimeFunction: conversionFunction
		arguments: {sourceValue}
		type: [ self halt ]
		name: (self convertName: instruction name).
	self convertDebugLocationFrom: instruction into: conversionResult.
	
	"We may need to truncate the result."
	targetSLVMType size < 4 ifTrue: [
		conversionResult := self truncate: conversionResult target: targetType name: nil
	].

	^ conversionResult
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
SLVMLLVMFunctionCodeGenerator >> visitFloatToDynamicObjectCast: instruction [
	| sourceType sourceValue targetType conversionFunction conversionResult |
	sourceType := instruction source type.
	sourceValue := self translateValue: instruction source.
	targetType := self translateType: instruction type.

	self assert: sourceType isFloatType.
	
	"Make sure the source type is at least a Float64"
	sourceType size < 8 ifTrue: [
		sourceValue := self castFloat: sourceValue into: self context doubleTy name: nil
	].

	conversionFunction := target objectModel float64ToFloatFunction.

	conversionResult := self callRuntimeFunction: conversionFunction
		arguments: {sourceValue}
		type: [ self halt ]
		name: (self convertName: instruction name).
	self convertDebugLocationFrom: instruction into: conversionResult.
	conversionResult type ~= targetType ifTrue: [
		conversionResult := self bitCast: conversionResult target: targetType name: nil
	].
	
	^ conversionResult
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitFloatToIntCast: instruction [
	instruction type isSigned ifTrue: [ 
		^ self fp: (self translateValue: instruction source) toSI: (self translateType: instruction type) name: (self convertName: instruction name)
	].
	^ self fp: (self translateValue: instruction source) toUI: (self translateType: instruction type) name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitFloatingPointCast: instruction [
	^ self castFloat: (self translateValue: instruction source)
		into: (self translateType: instruction type)
		name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitGetElementPointer: instruction [
	| canonicalFragments result |
	canonicalFragments := instruction canonicalFragmentsMappingIndicesWith: [:containerType :index |
		self mapContainerType: containerType index: index
	].

	result := self translateValue: instruction pointer.
	canonicalFragments do: [ :fragment |
		| expectedFragmentType lastContainerType |
		result := self addInstruction: (LLVMGetElementPtrInst new
			type: (self translateType: fragment type);
			pointer: result;
			indices: (fragment indices collect: [ :containerAndIndex | self translateValue: containerAndIndex second ]);
			yourself).
		
		expectedFragmentType := self translateType: fragment type.
		lastContainerType := fragment indices last first.
		lastContainerType isUnionType ifTrue: [
			| expectedResultType |
			expectedResultType := result type.
			result type: (LLVMPointerType get: (self translateType: lastContainerType) elements first addressSpace: expectedResultType addressSpace).
			result := self bitCast: result target: expectedResultType name: nil.
		]
	].

	result name: (self convertName: instruction name).
	^ result
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitGetExceptionSelectorFromTypeInfo: instruction [
	| typeInfo intrinsic voidPointerType |
	typeInfo := self translateValue: instruction typeInfoPointer.
	voidPointerType := self translateType: self target voidPointerType.
	typeInfo := LLVMBitCastConstantExpr new
						type: voidPointerType;
						source: typeInfo;
						yourself.
	intrinsic := self llvmModule getIntrinsic: #'llvm.eh.typeid.for' orCreateWithType: [
		LLVMFunctionType get: self context int32Ty params: {voidPointerType} isVarArg: false
	].

	^ self call: intrinsic arguments: { typeInfo } returnType: self context int32Ty name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitGetThisContext: instruction [
	| resultType intrinsic |
	resultType := self translateType: instruction type.
	self assert: instruction type = self target voidPointerType.

	"Functions that use thisContext cannot be inlined."
	(llvmFunction functionAttributes includes: #noinline) ifFalse: [
		llvmFunction functionAttributes: ((llvmFunction functionAttributes copyWithout: #alwaysinline) copyWith: #noinline)
	].

	self target supportsLocalAddressForThisContext ifTrue: [ 
		self flag: 'TODO: Make sure this is always the canonical frame address CFA.'.
		intrinsic := self llvmModule getIntrinsic: #'llvm.localaddress' orCreateWithType: [
			LLVMFunctionType get: resultType params: #() isVarArg: false
		].

		^ self call: intrinsic arguments: #() returnType: resultType name: (self convertName: instruction name)
	] ifFalse: [ 
		^ self bitCast: self getOrCreateThisContextLocalVariable target: resultType name: (self convertName: instruction name)
	].

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitInsertValue: instruction [
	^ self addInstruction: (LLVMInsertValueInst new
		name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		aggregate: (self translateValue: instruction aggregate);
		element: (self translateValue: instruction value);
		indices: instruction indices;
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitInsertVectorElement: instruction [
	^ self addInstruction: (LLVMInsertElementInst new
		name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		element: (self translateValue: instruction element);
		vector: (self translateValue: instruction vector);
		index: (self translateValue: instruction index);
		yourself)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitInstantiateClosure: instruction [
	| closurePrototype captures kind allocation dynamicCaptures normalCaptures normalFunctionType closureStructureType captureDefinitions environmentPtr |
	closurePrototype := self translateValue: instruction definition.
	captureDefinitions := instruction definition captures.
	dynamicCaptures := OrderedCollection new.
	normalCaptures := OrderedCollection new.
	
	instruction captures doWithIndex: [:capture :index |
		capture type isDynamicObjectPointerType ifTrue: [ 
			dynamicCaptures add: {captureDefinitions at: index . self translateValue: capture}
		] ifFalse: [ 
			normalCaptures add: {captureDefinitions at: index . self translateValue: capture}
		].
	].
	
	captures := dynamicCaptures asArray, normalCaptures asArray.
	kind := instruction closureType kind.
	normalFunctionType := instruction closureType normalFunctionTypeWith: self target hasStructReturnPointer: instruction definition hasStructReturnPointer.
	closureStructureType := normalFunctionType third.
	
	allocation := nil.
	(self target objectModel isClosureKindAllocatedInTheStack: kind) ifTrue: [
		allocation := self createSpillingAlloca: (self translateType: closureStructureType).
		self store: closurePrototype in: allocation.
	] ifFalse: [
		| uintType |
		uintType := self translateType: self target uintPointer.
		allocation := self callRuntimeFunction: self target objectModel gcBlockClosureAllocationFunction
			arguments: {
				uintType constant: closureStructureType size .
				uintType constant: closureStructureType alignment .
				closurePrototype }
			type: [ self halt ].
		self convertDebugLocationFrom: instruction into: allocation.
		allocation := self bitCast: allocation target: closurePrototype type name: nil.
	].
	
	self assert: allocation isNotNil.
	
	"Copy the captures"
	environmentPtr := self getReference: allocation constElement: closureStructureType types size - 1.
	captures doWithIndex: [ :captureDefinitionWithValue :index |
		| captureDefinition captureValue targetPointer copyFunction |
		captureDefinition := captureDefinitionWithValue first.
		captureValue := captureDefinitionWithValue second.
		targetPointer := self getReference: environmentPtr constElement: index - 1.
		
		captureDefinition copyFunction ifNil: [ 
			self store: captureValue in: targetPointer
		] ifNotNil: [
			copyFunction := self translateValue: captureDefinition copyFunction.
			self call: copyFunction arguments: { targetPointer . captureValue } returnType: copyFunction returnType name: nil.
		].
	].
	
	^ allocation
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitIntToDynamicObjectCast: instruction [
	| sourceType sourceValue targetType conversionFunction conversionResult |
	sourceType := instruction source type.
	sourceValue := self translateValue: instruction source.
	targetType := self translateType: instruction type.

	self assert: sourceType isIntegerType.
	
	"Make sure the source type is at least an Int32"
	sourceType size < 4 ifTrue: [
		sourceType isUnsigned ifTrue: [ 
			sourceValue := self zeroExtend: sourceValue target: self context int32Ty  name: nil
		] ifFalse: [ 
			sourceValue := self signExtend: sourceValue target: self context int32Ty  name: nil
		].
		
		sourceType := target int32
	].

	conversionFunction := sourceType size = 4 ifTrue: [
		sourceType isUnsigned ifTrue: [ 
			target objectModel uint32ToIntegerFunction.
		] ifFalse: [ 
			target objectModel int32ToIntegerFunction.
		].
	] ifFalse: [
		self assert: sourceType size = 8.
		sourceType isUnsigned ifTrue: [ 
			target objectModel uint64ToIntegerFunction.
		] ifFalse: [ 
			target objectModel int64ToIntegerFunction.
		].
	].

	conversionResult := self callRuntimeFunction: conversionFunction
		arguments: {sourceValue}
		type: [ self halt ]
		name: (self convertName: instruction name).
	self convertDebugLocationFrom: instruction into: conversionResult.
	conversionResult type ~= targetType ifTrue: [
		conversionResult := self bitCast: conversionResult target: targetType name: nil
	].
	
	^ conversionResult
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitIntToFloatCast: instruction [
	instruction source type isSigned ifTrue: [
		^ self si: (self translateValue: instruction source) toFP: (self translateType: instruction type) name: (self convertName: instruction name)
	].
	^ self ui: (self translateValue: instruction source) toFP: (self translateType: instruction type) name: (self convertName: instruction name)

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
SLVMLLVMFunctionCodeGenerator >> visitLandingPath: instruction [
	| resultType catchedExceptions |
	resultType := self translateType: instruction type.
	catchedExceptions := instruction catchedExceptions collect: [ :each | self translateValue: each ].
	^ self addInstruction: (LLVMLandingPadInst new
		name: (self convertName: instruction name);
		type: resultType;
		cleanup: instruction cleanup;
		catchedExceptions: catchedExceptions;
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
				| vectorParam |
				vectorParam := self translateValue: param.
				"Expand the vector param to the target size."
				(param type elements < vectorType elements) ifTrue: [ 
					vectorParam := self vector: vectorParam shuffleWith: vectorParam
						mask: ((0 to: vectorType elements - 1) collect: [ :mi | mi min: param type elements - 1 ])
				].
				
				resultInstruction := self vector: resultInstruction shuffleWith: vectorParam
						mask: ((0 to: vectorType elements - 1) collect: [:mi |
							mi < destIndex ifTrue: [
								mi
							] ifFalse: [
								mi - destIndex +  vectorType elements
							]
						]).
				out nextPut: resultInstruction.
				destIndex := destIndex + param type elements
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
	| returnType receiver arguments selector lookupResult calledFunctionType calledType functionPointer lookupArguments lookupFunction typeInfo lookupResultMethod lookupResultTrampoline |

	returnType := self translateType: instruction type.	
	receiver := self translateValue: instruction receiver.
	arguments := instruction arguments collect: [ :arg | self translateValue: arg ].
	selector := self translateValue: instruction selector.
	
	"Fetch the lookup typeinfo."
	instruction isSuperSend ifTrue: [
		| methodClassBinding methodClass typeInfoFetcher|
		methodClassBinding := self translateValue: function dynamicLiterals last.
		methodClass := self loadLiteralVariableValue: methodClassBinding.
		typeInfoFetcher := target objectModel methodSuperClassGetter.
		typeInfo := self callRuntimeFunction: typeInfoFetcher
			arguments: {methodClass}
			type: [ self halt ]
			name: nil.

	] ifFalse: [
		| typeInfoFetcher |
		typeInfoFetcher := target objectModel receiverClassGetter.
		typeInfo := self callRuntimeFunction: typeInfoFetcher
			arguments: {receiver}
			type: [ self halt ]
			name: nil.
	].
	self convertDebugLocationFrom: instruction into: typeInfo.

	"Lookup the message"
	lookupArguments := { receiver . selector . typeInfo.
		self nativeMethodDispatchTrampolineFor: instruction .
		self objectMethodDispatchTrampolineFor: instruction .
		self getOrCreateInlineCacheFor: instruction .}.
	lookupFunction := target objectModel messageLookupFunction.
	lookupResult := self callRuntimeFunction: lookupFunction
		arguments: lookupArguments
		type: [ self halt ]
		name: (self convertName: instruction name).
	self convertDebugLocationFrom: instruction into: lookupResult.
	
	"Cast the found message"
	lookupResultMethod := self aggregate: lookupResult extractValueAt: 0.
	lookupResultTrampoline := self aggregate: lookupResult extractValueAt: 1.
	calledFunctionType := SLVMFunctionType callingConvention: SLVMFunctionType cdeclCallingConvention
		arguments: {self target voidPointerType . instruction selector type . instruction receiver type} , (instruction arguments collect: #type)
		returnType: instruction type.
	calledType := self translateType: (target pointerTo: calledFunctionType).

	functionPointer := self bitCast: lookupResultTrampoline target: calledType name: nil.
	^ self call: functionPointer
		convention: (self convertCallingConvention: calledFunctionType callingConvention)
		arguments: {lookupResultMethod . selector . receiver}, arguments returnType: returnType name: nil.
	
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
SLVMLLVMFunctionCodeGenerator >> visitResumeException: instruction [
	^ self addInstruction: (LLVMResumeInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		value: (self translateValue: instruction value);
		yourself)
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
SLVMLLVMFunctionCodeGenerator >> visitShuffleVectors: instruction [
	| vectorType firstVector secondVector |
	vectorType := self translateType: instruction type.
	firstVector := self translateValue: instruction firstVector.
	secondVector := self translateValue: instruction secondVector.
	^ self vector: firstVector shuffleWith: secondVector mask: instruction components
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
SLVMLLVMFunctionCodeGenerator >> visitSwitch: instruction [
	^ self addInstruction: (LLVMSwitchInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		condition: (self translateValue: instruction matchedValue);
		defaultDest: (self translateValue: instruction defaultBlock);
		caseDests: (instruction caseBlocks collect: [:b | self translateValue: b]);
		caseValues: (instruction caseConstants collect: [:c | self translateValue: c]);
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
	self assert: (resultType isFloatingPointTy or: [resultType isVectorTy and: [resultType elementType isFloatingPointTy]]).
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
	| resultType operand intrinsic |
	resultType := self translateType: instruction type.
	operand := self translateValue: instruction operand.
	intrinsic := self getOverloadedIntrinsic: 'llvm.sqrt' argumentTypes: {resultType} returnType: resultType.
	^ self call: intrinsic arguments: {operand} returnType: resultType name: (self convertName: instruction name)
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnreachable: instruction [
	^ self addInstruction: (LLVMUnreachableInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		yourself)
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
