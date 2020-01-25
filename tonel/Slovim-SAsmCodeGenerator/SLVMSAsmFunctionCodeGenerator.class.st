Class {
	#name : #SLVMSAsmFunctionCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'target',
		'sasmTarget',
		'moduleTranslator',
		'function',
		'sasmFunction',
		'argumentVariableMap',
		'valueVariableMap',
		'basicBlockMap',
		'blockBuilder',
		'constantTranslator',
		'allocaToVariableMap',
		'returnArgumentType',
		'returnArgument',
		'returnArgumentRegister',
		'dynamicObjectVariableRegisters',
		'debugFunction'
	],
	#classVars : [
		'BuiltInFunctionSelectorMapping',
		'OperationCodeGeneratorMap'
	],
	#pools : [
		'SAsmTacOperations'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #'class initialization' }
SLVMSAsmFunctionCodeGenerator class >> initialize [
	BuiltInFunctionSelectorMapping := Dictionary newFromPairs: #(
		'atomic.fetch_and_add' generateFetchAndAdd:
		'atomic.fetch_and_subtract' generateFetchAndSubtract:
		'atomic.swap_value' generateSwapValue:
		'atomic.compare_and_swap' generateCompareAndSwap:
		
		'context.replace_function' generateContextReplaceFunction:
		'context.return_from_frame_value' generateReturnFromFrameValue:
	).
	
	OperationCodeGeneratorMap := Dictionary newFromPairs: #(
		add visitAdd:
		sub visitSub:
		mul visitMul:
		div visitDiv:
		udiv visitUDiv:
		rem visitRem:
		urem visitURem:
		neg visitNegate:
		not visitBitNot:
		lnot visitLogicalNot:
		
		bitand visitBitAnd:
		bitor visitBitOr:
		bitxor visitBitXor:
		
		shiftleft visitShiftLeft:
		shiftright visitShiftRight:
		rotateleft visitRotateLeft:
		rotateright visitRotateRight:
		shiftrightarithmetic visitShiftRightArithmetic:
		
		fadd visitFloatAdd:
		fsub visitFloatSub:
		fmul visitFloatMul:
		fdiv visitFloatDiv:
		fneg visitFloatNegate:
		fsqrt visitFloatSqrt:
		
		ilt visitIntegerLessThan:
		ile visitIntegerLessOrEqual:
		ieq visitIntegerEqual:
		ine visitIntegerNotEqual:
		igt visitIntegerGreaterThan:
		ige visitIntegerGreaterOrEqual:

		ult visitUnsignedIntegerLessThan:
		ule visitUnsignedIntegerLessOrEqual:
		ugt visitUnsignedIntegerGreaterThan:
		uge visitUnsignedIntegerGreaterOrEqual:

		uflt visitUnorderedFloatLessThan:
		ufle visitUnorderedFloatLessOrEqual:
		ufeq visitUnorderedFloatEqual:
		ufne visitUnorderedFloatNotEqual:
		ufgt visitUnorderedFloatGreaterThan:
		ufge visitUnorderedFloatGreaterOrEqual:

		oflt visitOrderedFloatLessThan:
		ofle visitOrderedFloatLessOrEqual:
		ofeq visitOrderedFloatEqual:
		ofne visitOrderedFloatNotEqual:
		ofgt visitOrderedFloatGreaterThan:
		ofge visitOrderedFloatGreaterOrEqual:
		
		dynObjectIdentityEquals visitIdentityEquals:
		dynObjectIdentityNotEquals visitIdentityNotEquals:
		
		mulMatrixMatrix visitMultiplyMatrixWithMatrix:
		mulMatrixVector visitMultiplyMatrixWithVector:
		mulVectorMatrix visitMultiplyVectorWithMatrix:
	).
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> binaryFloat: instruction arithmetic: operation [
	| left leftValue right rightValue resultValue |
	left := instruction left.
	leftValue := self translateValue: left.
	
	right := instruction right.
	rightValue := self translateValue: right.
	
	resultValue := self translateValue: instruction.
	
	self assert: leftValue size = rightValue size.
	self assert: leftValue size = resultValue size.
	self assert: instruction left type = instruction right type.
	resultValue size ~= 1 ifTrue: [
		"Handle the multi-register case in a special way"
		self halt.
	].
	
	^ blockBuilder tacOperation: operation result: resultValue left: leftValue right: rightValue
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> binaryInteger: instruction arithmetic: operation [
	| left leftValue right rightValue resultValue |
	left := instruction left.
	leftValue := self translateValue: left.
	
	right := instruction right.
	rightValue := self translateValue: right.
	
	resultValue := self translateValue: instruction.
	
	self assert: leftValue size = rightValue size.
	self assert: leftValue size = resultValue size.
	self assert: instruction left type = instruction right type.
	resultValue size ~= 1 ifTrue: [
		"Handle the multi-register case in a special way"
		self halt.
	].
	
	^ blockBuilder tacOperation: operation result: resultValue left: leftValue right: rightValue
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> binaryInteger: instruction bitwise: operation [
	| left leftValue right rightValue resultValue |
	left := instruction left.
	leftValue := self translateValue: left.
	
	right := instruction right.
	rightValue := self translateValue: right.
	
	resultValue := self translateValue: instruction.
	self assert: instruction left type = instruction right type.
	self elementWise: leftValue with: rightValue with: resultValue do: [ :leftElement :rightElement :resultElement |
		^ blockBuilder tacOperation: operation result: resultElement left: leftElement right: rightElement
	]
	
	
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> binaryInteger: instruction comparison: comparison [
	| left right result type |
	left := self translateValue: instruction left.
	right := self translateValue: instruction right.
	result := self translateValue: instruction.
	type := instruction type.
	self assert: left isOperandSet.
	self assert: right isOperandSet.
	self assert: result isOperandSet.
	self assert: left size = right size.
	type isBooleanType ifTrue: [ 
		self assert: result size = 1.
		self compare: comparison integer: left with: right into: result.
	] ifFalse: [
		self assert: result size >= left size.
		result size > left size ifTrue: [ 
			self halt
		] ifFalse: [ 
			self halt.
			1 to: result size do: [ :i |
				self compare: comparison integer: (left at: i) with: (right at: i) into: (result at: i).
			]
		]
	]
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> compare: comparison integer: left with: right into: result [
	left size == 1 ifTrue: [ 
		blockBuilder tacOperation: comparison result: result left: left right: right
	] ifFalse: [ 
		"Big integer"
		self halt.
	]

]

{ #category : #accessing }
SLVMSAsmFunctionCodeGenerator >> constantTranslator [
	^ constantTranslator ifNil: [ constantTranslator :=
		SLVMSAsmConstantCodeGenerator new
			target: target;
			sasmTarget: sasmTarget;
			moduleElement: sasmFunction;
			moduleTranslator: moduleTranslator;
			yourself
	]
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createAllocaVariables [
	| registers |
	allocaToVariableMap := Dictionary new.
	dynamicObjectVariableRegisters := OrderedCollection new.
	
	function basicBlocks first allocaInstructionsDo: [ :alloca |
		alloca isOnlyUsedByLoadStore ifTrue: [
			registers := self createVirtualRegistersForType: alloca valueType.
			self createRegisters: registers debugVariable: alloca type: alloca valueType.
			
			allocaToVariableMap at: alloca put: registers.
			alloca instructionReferences do: [ :ref |
				ref isLoad ifTrue: [ valueVariableMap at: ref put: registers ].
			].
		
			alloca valueType isDynamicObjectPointerType ifTrue: [
				dynamicObjectVariableRegisters add: registers
			] 
		]
	]
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createArguments [
	| stackFrameLayout returnType functionType variable |
	stackFrameLayout := sasmFunction stackFrameLayout.
	argumentVariableMap := Dictionary new.
	
	returnType := function functionType returnType.
	(returnType isStructureType or: [returnType isUnionType]) ifTrue: [
		returnArgumentType := SLVMPointerType size: target pointerSize baseType: returnType storage: SLVMPointerType genericStorage.
		returnArgument := stackFrameLayout createArgument: returnArgumentType spillingClass registerClass: returnArgumentType registerClass.
		returnArgumentRegister := self createVirtualRegistersForVariable: returnArgument type: returnArgumentType.
	].
	functionType := function functionType.
	function arguments doWithIndex: [ :arg :index |
		variable := stackFrameLayout createArgument: arg type spillingClass registerClass: arg type registerClass dynamicRoot: (functionType argumentAt: index hasAttribute: #dynobject).
		sasmFunction debugArguments ifNotNil: [ 
			self createVariable: variable debugVariable: arg debugInformationEntry: (sasmFunction debugArguments at: index).
		].
		argumentVariableMap at: arg put: variable.
	]
]

{ #category : #'debug information' }
SLVMSAsmFunctionCodeGenerator >> createRegisters: registers debugVariable: valueWithDebugInformation [
	self createRegisters: registers debugVariable: valueWithDebugInformation type: valueWithDebugInformation type
]

{ #category : #'debug information' }
SLVMSAsmFunctionCodeGenerator >> createRegisters: registers debugVariable: valueWithDebugInformation type: type [
	valueWithDebugInformation debugInformation ifNotNil: [ :debugInfo |
		registers debugInformation: debugInfo.
		sasmFunction debugFunction builder variable: [ :variable |
			variable
				name: debugInfo name;
				type: (moduleTranslator translateDebugType: type).
			variable location build: [ :builder | builder registers: registers registers ].
		]
	].

]

{ #category : #'debug information' }
SLVMSAsmFunctionCodeGenerator >> createVariable: variable debugVariable: valueWithDebugInformation [
	^ self createVariable: variable debugVariable: valueWithDebugInformation type: valueWithDebugInformation type
]

{ #category : #'debug information' }
SLVMSAsmFunctionCodeGenerator >> createVariable: variable debugVariable: valueWithDebugInformation debugInformationEntry: debugInformationEntry [
	valueWithDebugInformation debugInformation ifNotNil: [ :debugInfo |
		variable debugInformation: debugInfo.
		debugInformationEntry location build: [ :locationBuilder |
			locationBuilder variable: variable
		]
	].

]

{ #category : #'debug information' }
SLVMSAsmFunctionCodeGenerator >> createVariable: variable debugVariable: valueWithDebugInformation type: type [
	valueWithDebugInformation debugInformation ifNotNil: [ :debugInfo |
		variable debugInformation: debugInfo.
		sasmFunction debugFunction builder variable: [ :debugVariable |
			debugVariable
				name: debugInfo name;
				type: (moduleTranslator translateDebugType: type).
			debugVariable location build: [ :builder | builder variable: variable ].
		]
	].

]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createVirtualRegisters [
	| argumentVariable argumentRegisters type |
	valueVariableMap := Dictionary new.
	function arguments do: [ :argValue |
		argumentVariable := argumentVariableMap at: argValue.
		argumentRegisters := self createVirtualRegistersForVariable: argumentVariable type: argValue type.
		valueVariableMap at: argValue put: argumentRegisters.
	].

	self createAllocaVariables.

	function basicBlocks do: [ :basicBlock |
		basicBlock instructionsDo: [ :instruction |
			(self isNopBitCast: instruction) ifFalse: [ 
				type := instruction type.
				type isVoidType ifFalse: [ 
					valueVariableMap at: instruction ifAbsentPut: [self createVirtualRegistersForType: type andInstruction: instruction].
				]
			]
		]
	].

	"Nop some instructions"
	function basicBlocks do: [ :basicBlock |
		basicBlock instructionsDo: [ :instruction |
			(self isNopBitCast: instruction) ifTrue: [ 
				valueVariableMap at: instruction ifAbsentPut: [self translateValue: instruction source]
			]
		]
	].


]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createVirtualRegistersForType: type [
	type isScalarType ifTrue: [ 
		type isScalarIntegerType ifTrue: [
			^ SLVMSAsmValue registers: (sasmFunction addVirtualRegisters: (sasmTarget newIntegerVirtualRegistersForSize: type size dynamicRoot: type isDynamicObjectPointerType))
		].
		type isFloatType ifTrue: [
			^ SLVMSAsmValue registers: (sasmFunction addVirtualRegisters: (sasmTarget newFloatVirtualRegistersForSize: type size))
		].
	].

	type isVectorType ifTrue: [ 
		self halt.
	].

	^ SLVMSAsmValue variable: (sasmFunction stackFrameLayout createLocal: type spillingClass)

]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createVirtualRegistersForType: type andInstruction: instruction [
	| result |
	result := self createVirtualRegistersForType: type.
	(instruction isAlloca and: [ instruction block index = 1 ]) ifFalse: [
		self createRegisters: result debugVariable: instruction.
	].
	^ result
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createVirtualRegistersForVariable: variable type: type [
	| registers |
	registers := self createVirtualRegistersForType: type.
	registers isAggregate ifTrue: [ ^ registers ].
	
	registers doWithIndex: [ :reg :index |
		reg
			variable: variable;
			variableOffset: (index - 1) * reg size
	].
	^ registers
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> elementWise: source with: result do: aBlock [
	self assert: source size = result size.
	1 to: source size do: [ :i |
		aBlock value: (source at: i) value: (result at: i)
	]
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> elementWise: source with: source2 with: result  do: aBlock [
	self assert: source size = result size.
	self assert: source2 size = result size.
	1 to: source size do: [ :i |
		aBlock value: (source at: i) value: (source2 at: i) value: (result at: i)
	]
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> emitCastInstruction: instruction byCalling: convertionFunction [
	^ self emitCastInstruction: instruction byCalling: convertionFunction intoResult: (self translateValue: instruction)
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> emitCastInstruction: instruction byCalling: convertionFunction intoResult: result [
	| castedValue |
	castedValue := self translateValue: instruction source.
	^ self emitCastOfValue: castedValue byCalling: convertionFunction intoResult: result
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> emitCastOfValue: castedValue byCalling: convertionFunction intoResult: result [
	| convertionFunctionValue |
	convertionFunctionValue := self translateValue: convertionFunction.
	blockBuilder tacCall: convertionFunctionValue
		arguments: { castedValue asSAsmInstructionOperand }
		into: {result} convention: (sasmTarget callingConventionNamed: convertionFunction callingConvention).
	^ result
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> emitIntructionDebugInformation: instruction [
	target emittingDebugInformation ifFalse: [ ^ self ].
	instruction debugSourceLocation ifNotNil: [ 
		blockBuilder debugSourceLocation: instruction debugSourceLocation
	]
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> emitPrologueInstructions [
	dynamicObjectVariableRegisters do: [ :reg |
		blockBuilder tacMove: 0 into: reg
	]
]

{ #category : #'as yet unclassified' }
SLVMSAsmFunctionCodeGenerator >> ensureFunctionContextMetaDataIsPresent [
	moduleTranslator createFunctionContextMetaData: function
]

{ #category : #'atomic operations' }
SLVMSAsmFunctionCodeGenerator >> generateCompareAndSwap: instruction [
	| result variable value |
	result := self translateValue: instruction.
	variable := self translateValue: instruction arguments first.
	value := self translateValue: instruction arguments second.
	self assert: variable size = 1.
	self assert: value size = 1.
	self assert: result size = 1.

	blockBuilder tacAtomicCompareAndSwap: variable first with: value first into: result first
]

{ #category : #'atomic operations' }
SLVMSAsmFunctionCodeGenerator >> generateContextReplaceFunction: instruction [
	| newFunction |
	newFunction := self translateValue: instruction arguments first.
	self assert: newFunction size = 1.

	blockBuilder
		tacContextReplaceFunction: newFunction
]

{ #category : #'atomic operations' }
SLVMSAsmFunctionCodeGenerator >> generateFetchAndAdd: instruction [
	| result variable value |
	result := self translateValue: instruction.
	variable := self translateValue: instruction arguments first.
	value := self translateValue: instruction arguments second.
	self assert: variable size = 1.
	self assert: value size = 1.
	self assert: result size = 1.

	blockBuilder tacAtomicFetchAndAdd: variable with: value into: result
]

{ #category : #'atomic operations' }
SLVMSAsmFunctionCodeGenerator >> generateFetchAndSubtract: instruction [
	| result variable value tempValue |
	result := self translateValue: instruction.
	variable := self translateValue: instruction arguments first.
	value := self translateValue: instruction arguments second.
	self assert: variable size = 1.
	self assert: value size = 1.
	self assert: result size = 1.

	tempValue := blockBuilder tacIntRegister.
	blockBuilder tacNegate: value first into: tempValue.
	blockBuilder tacAtomicFetchAndAdd: variable first with: tempValue into: result first
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> generateFunction: slvmFunction into: newSasmFunction [
	slvmFunction isEmpty ifTrue: [ ^ newSasmFunction ].
	
	function := slvmFunction.
	sasmFunction := newSasmFunction.
	sasmFunction callingConventionNamed: function callingConvention.
	debugFunction := newSasmFunction debugFunction.
	self
		createArguments;
		createVirtualRegisters;
		translateBasicBlocks;
		postProcessCodeGeneration.

]

{ #category : #'atomic operations' }
SLVMSAsmFunctionCodeGenerator >> generateReturnFromFrameValue: instruction [
	| newFrame returnValue exitPoint |
	newFrame := self translateValue: instruction arguments first.
	exitPoint := self translateValue: instruction arguments second.
	returnValue := self translateValue: instruction arguments third.
	self assert: newFrame size = 1.
	self assert: exitPoint size = 1.

	blockBuilder
		tacReturnFromFrame: newFrame exitPoint: exitPoint value: returnValue
]

{ #category : #'atomic operations' }
SLVMSAsmFunctionCodeGenerator >> generateSwapValue: instruction [
	| result variable value |
	result := self translateValue: instruction.
	variable := self translateValue: instruction arguments first.
	value := self translateValue: instruction arguments second.
	self assert: variable size = 1.
	self assert: value size = 1.
	self assert: result size = 1.

	blockBuilder tacAtomicSwap: variable with: value into: result
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> increaseReferenceOf: aValue [
	| increaseReferenceFunction |
	increaseReferenceFunction := target objectModel increaseReference.
	increaseReferenceFunction ifNil: [ ^ self ].
	
	blockBuilder tacCall: (self translateValue: increaseReferenceFunction)
		arguments: { self translateValue: aValue }
			into: #() convention: (sasmTarget callingConventionNamed: increaseReferenceFunction callingConvention)
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> isNopBitCast: instruction [
	^ instruction isBitCast and: [ instruction canBeNop ]
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> loadFrom: pointer scalarType: type into: result [
	| temp |
	self assert: type isScalarType.
	
	(type isPointerType or: [ type isDynamicObjectPointerType ]) ifTrue: [
		self assert: result isRegisterScalarValue.
		^ blockBuilder tacLoad: pointer into: result
	].
	type isFloatType ifTrue: [
		self assert: result isRegisterScalarValue.
		type size = 4 ifTrue: [ 
			^ blockBuilder tacLoadFloat: pointer into: result
		].
		type size = 8 ifTrue: [ 
			^ blockBuilder tacLoadDouble: pointer into: result
		].
		self halt
	].

	type isBooleanType ifTrue: [
		^ blockBuilder tacLoadZeroExtend8: pointer into: result
	].

	type isIntegerType ifTrue: [
		type size <= 4 ifTrue: [ 
			self assert: result isRegisterScalarValue.
			type isSigned ifTrue: [
				type size = 1 ifTrue: [ ^ blockBuilder tacLoadSignExtend8: pointer into: result ].
				type size = 2 ifTrue: [ ^ blockBuilder tacLoadSignExtend16: pointer into: result ].
				type size = 4 ifTrue: [ ^ blockBuilder tacLoadSignExtend32: pointer into: result ].
			] ifFalse: [ 
				type size = 1 ifTrue: [ ^ blockBuilder tacLoadZeroExtend8: pointer into: result ].
				type size = 2 ifTrue: [ ^ blockBuilder tacLoadZeroExtend16: pointer into: result ].
				type size = 4 ifTrue: [ ^ blockBuilder tacLoadZeroExtend32: pointer into: result ].
			].
		
			self error: 'Unsupported integer type.'
		].
	
		self assert: type size = 8.
		result size = 1 ifTrue: [ 
			^ blockBuilder tacLoad: pointer into: result.
		] ifFalse: [ 
			self assert: result size = 2.
			temp := blockBuilder tacIntRegister.
			sasmTarget isLittleEndian ifTrue: [ 
				^ blockBuilder
					tacLoad: pointer into: (result at: 1);
					tacAdd: pointer with: 4 into: temp;
					tacLoad: temp into: (result at: 2)
			] ifFalse: [ 
				^ blockBuilder
					tacLoad: pointer into: (result at: 2);
					tacAdd: pointer with: 4 into: temp;
					tacLoad: temp into: (result at: 1)
			]
		]
	].

	self error: 'Unsupported scalar type loading.'.
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> loadFromPointer: pointer type: type into: targetValue [
	type isScalarType ifTrue: [
		^ self loadFrom: pointer scalarType: type into: targetValue
	].

	"Aggregate type. We have to copy."
	self assert: targetValue isAggregate.
	blockBuilder tacCopy: pointer to: targetValue size: type size alignment: type alignment.
]

{ #category : #accessing }
SLVMSAsmFunctionCodeGenerator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMSAsmFunctionCodeGenerator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> move: sourceValue into: targetValue [
	self assert: sourceValue isOperandSet = targetValue isOperandSet.
	sourceValue isOperandSet ifTrue: [ 
		self assert: sourceValue size = targetValue size.
		1 to: sourceValue size do: [ :index |
			blockBuilder tacMove: (sourceValue at: index) into: (targetValue at: index)
		]
	] ifFalse: [ 
		self halt
	].

]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> postProcessCodeGeneration [
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> runtimeProvidedFunction: aFunctionOrASymbol [
	^ moduleTranslator runtimeProvidedFunction: aFunctionOrASymbol
	
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> store: ssaValue intoPointerRegister: variable [

	| value type |
	value := self translateValue: ssaValue.
	type := ssaValue type.

	type isScalarType ifTrue: [
		^ self store: value scalarType: type into: variable
	].

	"Aggregate type. We have to copy."

	self halt.

]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> store: value scalarType: type into: pointer [
	| temp |
	self assert: type isScalarType.
	(type isPointerType or: [ type isDynamicObjectPointerType ]) ifTrue: [
		self assert: value isRegisterScalarValue.
		^ blockBuilder tacStore: value into: pointer.
	].
	type isFloatType ifTrue: [
		self assert: value isRegisterScalarValue.
		type size = 4 ifTrue: [
			^ blockBuilder tacStoreFloat: value into: pointer
		].
		type size = 8 ifTrue: [
			^ blockBuilder tacStoreDouble: value into: pointer
		].
		self halt
	].

	type isBooleanType ifTrue: [
		^ blockBuilder tacStoreTruncate8: value into: pointer
	].

	type isIntegerType ifTrue: [
		type size <= 4 ifTrue: [ 
			self assert: value isRegisterScalarValue.
			type size = 1 ifTrue: [ ^ blockBuilder tacStoreTruncate8: value into: pointer ].
			type size = 2 ifTrue: [ ^ blockBuilder tacStoreTruncate16: value into: pointer ].
			type size = 4 ifTrue: [ ^ blockBuilder tacStoreTruncate32: value into: pointer ].
		
			self error: 'Unsupported integer type.'
		].
	
		self assert: type size = 8.
		value size = 1 ifTrue: [ 
			^ blockBuilder tacStore: value into: pointer
		] ifFalse: [ 
			self assert: (value isOperandSet and: [value size = 2]).
			temp := blockBuilder tacIntRegister.
			sasmTarget isLittleEndian ifTrue: [
				^ blockBuilder
					tacStore: (value at: 1) into: pointer;
					tacAdd: pointer with: 4 into: temp;
					tacStore: (value at: 2) into: pointer
			] ifFalse: [
				^ blockBuilder
					tacStore: (value at: 2) into: pointer;
					tacAdd: pointer with: 4 into: temp;
					tacStore: (value at: 1) into: pointer
			]
		]
	].

	self error: 'Unsupported scalar type storing.'.
]

{ #category : #accessing }
SLVMSAsmFunctionCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMSAsmFunctionCodeGenerator >> target: aCompilationTarget [
	target := aCompilationTarget.
	sasmTarget := aCompilationTarget target.
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> translateBasicBlock: basicBlock [
	basicBlock index = 1 ifTrue: [ 
		self emitPrologueInstructions
	].

	basicBlock instructionsDo: [ :instruction |
		"Do not generate unused values."
		(instruction isPureInstruction and: [ instruction instructionReferences isEmpty]) ifFalse: [
			self emitIntructionDebugInformation: instruction.
			instruction accept: self
		]
	]
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> translateBasicBlocks [
	| lowBasicBlock blocks |
	basicBlockMap := Dictionary new.
	blocks := function dominanceTopoSort.
	blocks do: [ :bb |
		lowBasicBlock := SAsmBasicBlock new name: bb name.
		sasmFunction addBasicBlock: lowBasicBlock.
		basicBlockMap at: bb put: lowBasicBlock
	].

	blocks do: [ :bb |
		lowBasicBlock := basicBlockMap at: bb.
		lowBasicBlock build: [ :builder |
			blockBuilder := builder.
			self translateBasicBlock: bb
		]
	].
	
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> translateConstant: value [
	| result loadedLiteral |
	valueVariableMap at: value ifPresent: [ :oldValue | ^ oldValue ].
	
	result := self constantTranslator translate: value.
	value isConstantDynamicLiteral ifTrue: [
		loadedLiteral := blockBuilder tacIntRegister.
		blockBuilder tacLoad: result into: loadedLiteral.
		^ SLVMSAsmValue registers: { loadedLiteral }
	].

	valueVariableMap at: value put: result.

	^ result
	
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> translateValue: value [
	value isConstant ifTrue: [ ^ self translateConstant: value ].
	(value isFunctionArgument or: [ value isInstruction ]) ifTrue: [ ^ valueVariableMap at: value ].

	self halt.
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> unaryFloat: instruction arithmetic: operation [
	| resultValue operand operandValue |
	operand := instruction operand.
	operandValue := self translateValue: operand.
	
	resultValue := self translateValue: instruction.
	
	self assert: operandValue size = resultValue size.
	resultValue size ~= 1 ifTrue: [
		"Handle the multi-register case in a special way"
		self halt.
	].
	
	^ blockBuilder tacOperation: operation result: resultValue value: operandValue
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> unaryInteger: instruction arithmetic: operation [
	| resultValue operand operandValue |
	operand := instruction operand.
	operandValue := self translateValue: operand.
	
	resultValue := self translateValue: instruction.
	
	self assert: operandValue size = resultValue size.
	resultValue size ~= 1 ifTrue: [
		"Handle the multi-register case in a special way"
		self halt.
	].
	
	^ blockBuilder tacOperation: operation result: resultValue value: operandValue
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> unaryInteger: instruction bitwise: tacOperation [
	^ self unaryInteger: instruction arithmetic: tacOperation
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitAdd: instruction [
	self binaryInteger: instruction arithmetic: TacAdd
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitAlloca: instruction [
	| valueType result variable |
	(allocaToVariableMap includesKey: instruction) ifTrue: [ ^ self ].
	valueType := instruction valueType.
	result := self translateValue: instruction.
	instruction block == function basicBlocks first ifTrue: [ 
		variable := sasmFunction newLocal: valueType size alignment: valueType alignment dynamicRoot: valueType isDynamicObjectPointerType.
		variable explicitLocalVariable: true.
		self createVariable: variable debugVariable: instruction type: valueType.
		blockBuilder tacLoadLocalAddress: variable into: result
	] ifFalse: [ 
		self halt.
	]
	
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitBinaryOperation: instruction [
	| selector |
	selector := OperationCodeGeneratorMap at: instruction operation.
	^ self perform: selector with: instruction

]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitBitAnd: instruction [
	self binaryInteger: instruction bitwise: TacBitAnd
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitBitCast: instruction [
	| sourceValue result |
	(self isNopBitCast: instruction) ifTrue: [ ^ self ].
	
	sourceValue := self translateValue: instruction source.
	result := self translateValue: instruction.
	sourceValue ~~ result ifTrue: [
		(instruction source type isFloatType and: [ instruction type isIntegerType ]) ifTrue: [			
			self assert: sourceValue size = 1.
			self assert: result size = 1.
			^ blockBuilder tacReinterpretFloat: sourceValue asIntegerInto: result
		].
		(instruction source type isIntegerType and: [ instruction type isFloatType  ]) ifTrue: [
			self assert: sourceValue size = 1.
			self assert: result size = 1.
			^ blockBuilder tacReinterpretInteger: sourceValue asFloatInto: result
		].
	
		self move: sourceValue into: result
	].
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitBitNot: instruction [
	self unaryInteger: instruction bitwise: TacBitNot
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitBitOr: instruction [
	self binaryInteger: instruction bitwise: TacBitOr
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitBitXor: instruction [
	self binaryInteger: instruction bitwise: TacBitXor
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitBoolToDynamicObjectCast: instruction [
	| source result |
	source := self translateValue: instruction source.
	result := self translateValue: instruction.
	
	^ self emitCastOfValue: source byCalling: target objectModel boolToObjectFunction intoResult: result
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitBranch: instruction [
	| condition trueDestination falseDestination |
	condition := self translateValue: instruction condition.
	self assert: condition size = 1.

	trueDestination := basicBlockMap at: instruction trueBlock.
	falseDestination := basicBlockMap at: instruction falseBlock.
	instruction condition isConstantValue ifTrue: [
		instruction condition value ifTrue: [
			^ blockBuilder tacJump: trueDestination
		] ifFalse: [
			^ blockBuilder tacJump: falseDestination
		]
	].


	blockBuilder tacBranch: condition true: trueDestination false: falseDestination.
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitCall: instruction [
	| calledFunction arguments result calledConvention callInstruction |
	instruction functionValue isConstantBuiltInFunction ifTrue: [
		BuiltInFunctionSelectorMapping at: instruction functionValue name ifPresent: [ :selector |
			^ self perform: selector with: instruction
		].
		self halt
	].

	instruction type isVoidType ifTrue: [
		result := #()
	] ifFalse: [ 
		result := self translateValue: instruction
	].
	arguments := OrderedCollection new.
	instruction arguments do: [ :arg | arguments addAll: (self translateValue: arg) ].
	
	calledFunction := self translateValue: instruction functionValue.
	calledConvention := sasmTarget callingConventionNamed: instruction callingConvention.
	calledConvention hasContextMetadata ifTrue: [ self ensureFunctionContextMetaDataIsPresent ].
	
	self assert: calledFunction size = 1.
	callInstruction := blockBuilder tacCall: calledFunction arguments: arguments into: result convention: calledConvention.
	
	instruction functionType variadic ifTrue: [ 
		callInstruction isVarArgs: true
	]
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitClosureToDynamicObject: anInstruction [
	| result closure |
	closure := self translateValue: anInstruction source.
	result := self translateValue: anInstruction.
	blockBuilder tacMove: closure into: result
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitConstantUndefined: instruction [
	| result |
	result := self translateValue: instruction.
	instruction type isDynamicObjectPointerType ifTrue: [
		^ blockBuilder tacMove: 0 into: result
	]
]

{ #category : #'debug instructions' }
SLVMSAsmFunctionCodeGenerator >> visitDebugInstructionDeclareVariable: instruction [
]

{ #category : #'debug instructions' }
SLVMSAsmFunctionCodeGenerator >> visitDebugInstructionSetVariableValue: instruction [
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitDiv: instruction [
	self binaryInteger: instruction arithmetic: TacDivide
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitDynamicObjectToBoolCast: instruction [
	| result |
	result := self translateValue: instruction.
	self emitCastInstruction: instruction byCalling: target objectModel objectToBoolFunction intoResult: result.
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitDynamicObjectToFloatCast: instruction [
	| result resultTemp |
	result := self translateValue: instruction.
	resultTemp := result.
	instruction type size ~= 8 ifTrue: [ 
		resultTemp := blockBuilder tacDoubleFloatRegister.
	].

	self emitCastInstruction: instruction byCalling: target objectModel objectToFloatFunction intoResult: resultTemp.
	
	instruction type size = 8 ifTrue: [
		self assert: resultTemp == result.
		^ self
	].
	instruction type size = 4 ifTrue: [
		blockBuilder tacDouble: resultTemp intoFloat: result
	].
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitDynamicObjectToIntCast: instruction [
	| source sourceValue result |
	source := instruction source.
	source isConstantValue ifTrue: [ 
		self halt
	].

	sourceValue := self translateValue: source.
	result := self translateValue: instruction.
	self assert: source type isDynamicObjectPointerType.

	self flag: 'Check for overflows'.
	blockBuilder tacArithmeticShiftRight: sourceValue with: target objectModel smallIntegerShift into: result
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitDynamicObjectToPointerCast: instruction [
	| convertionFunction typeObject result convertionFunctionValue object |
	object := self translateValue: instruction source.
	typeObject := self translateValue: instruction typeObject.
	result := self translateValue: instruction.
	
	convertionFunction := target objectModel objectToPointerFunction.
	convertionFunctionValue := self translateValue: convertionFunction.
	blockBuilder tacCall: convertionFunctionValue
		arguments: { object registers first . typeObject registers first }
		into: result convention: (sasmTarget callingConventionNamed: convertionFunction callingConvention)
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> visitExtractValue: instruction [
	| aggregate result offset type indexConstant fieldPointer |
	offset := 0.
	type := instruction aggregate type.
	instruction indices do: [ :index |
		indexConstant := SLVMConstant int: index.
		offset := type offsetWithIndex: indexConstant.
		type := type typeOfMemberAt: indexConstant
	].

	aggregate := self translateValue: instruction aggregate.
	result := self translateValue: instruction.
	
	fieldPointer := blockBuilder tacIntRegister.
	blockBuilder tacAdd: aggregate with: offset into: fieldPointer.
	self loadFromPointer: fieldPointer type: type into: result	
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitFloatAdd: instruction [
	self binaryFloat: instruction arithmetic: TacFloatAdd
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitFloatDiv: instruction [
	self binaryFloat: instruction arithmetic: TacFloatDivide
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitFloatMul: instruction [
	self binaryFloat: instruction arithmetic: TacFloatMultiply
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitFloatNegate: instruction [
	self unaryFloat: instruction arithmetic: TacFloatNegate
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitFloatSqrt: instruction [
	self unaryFloat: instruction arithmetic: TacFloatSqrt
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitFloatSub: instruction [
	self binaryFloat: instruction arithmetic: TacFloatSubtract
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitFloatToDynamicObjectCast: instruction [
	| source sourceValue result doubleSource |
	source := instruction source.
	sourceValue := self translateValue: source.
	result := self translateValue: instruction.
		
	source type size ~= 8 ifTrue: [
		self assert: source type size = 4.
		doubleSource := blockBuilder tacDoubleFloatRegister.
		blockBuilder tacFloat: sourceValue intoDouble: doubleSource.
		sourceValue := doubleSource
	].

	^ self emitCastOfValue: sourceValue byCalling: target objectModel floatToObjectFunction intoResult: result
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitFloatToIntCast: instruction [
	| result source sourceSize resultSize isSigned |
	result := self translateValue: instruction.
	source := self translateValue: instruction source.
	isSigned := instruction type isSigned.
	sourceSize := instruction source type size.
	resultSize := instruction type size.
	resultSize < 4 ifTrue: [
		self halt
	].

	resultSize = 4 ifTrue: [
		sourceSize = 4 ifTrue: [
			isSigned ifTrue: [
				^ blockBuilder tacFloat: source intoInt32: result
			] ifFalse: [ 
				^ blockBuilder tacFloat: source intoUInt32: result
			]
		] ifFalse: [
			self assert: sourceSize = 8.
			isSigned ifTrue: [
				^ blockBuilder tacDouble: source intoInt32: result
			] ifFalse: [ 
				^ blockBuilder tacDouble: source intoUInt32: result
			]
		]
	].

	resultSize = 8 ifTrue: [
		target pointerSize = 8 ifTrue: [ 
			sourceSize = 4 ifTrue: [
				self halt
				isSigned ifTrue: [
					^ blockBuilder tacFloat: source intoInt64: result
				] ifFalse: [ 
					^ blockBuilder tacFloat: source intoUInt64: result
				]
			] ifFalse: [
				self assert: sourceSize = 8.
				isSigned ifTrue: [
					^ blockBuilder tacDouble: source intoInt64: result
				] ifFalse: [ 
					^ blockBuilder tacDouble: source intoUInt64: result
				]
			]

		] ifFalse: [ 
			self halt
		].
	].

	self error: 'Unsupported float to integer cast variant'.
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitFloatingPointCast: instruction [
	| source sourceValue result sourceSize resultSize |
	source := instruction source.
	sourceValue := self translateValue: source.
	result := self translateValue: instruction.
	self assert: source type isFloatType.
	sourceSize := source type size.
	resultSize := instruction type size.
	(sourceSize = 4 and: [ resultSize = 8 ]) ifTrue:[
		^ blockBuilder tacFloat: sourceValue intoDouble: result
	].
	(sourceSize = 8 and: [ resultSize = 4 ]) ifTrue:[
		^ blockBuilder tacDouble: sourceValue intoFloat: result
	].

	self error: 'Unsupported floating point cast'
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitGetElementPointer: instruction [
	| constantDisplacement indicesWithStrides pointer result indexValue temp rawIndicesWithStrides |
	constantDisplacement := 0.
	indicesWithStrides := OrderedCollection new.
	
	instruction pointer type isDynamicObjectPointerType ifTrue: [
		constantDisplacement := target objectModel objectHeaderSize
	].

	rawIndicesWithStrides := instruction indicesWithStrides.
	
	rawIndicesWithStrides do: [ :indexStrideOffset |
		indexStrideOffset second ~= 0 ifTrue: [ 
			indicesWithStrides add: { indexStrideOffset first . indexStrideOffset second }
		].
	
		constantDisplacement := constantDisplacement + indexStrideOffset third.
	].

	"Get the pointer. It should always fit in a single register."
	pointer := self translateValue: instruction pointer.
	self assert: pointer size = 1.
	
	result := self translateValue: instruction.
	self assert: result size = 1.

	constantDisplacement ~= 0 ifTrue: [ 
		blockBuilder tacAdd: pointer with: constantDisplacement into: result
	] ifFalse: [
		blockBuilder tacMove: pointer into: result
	].

	temp := nil.
	indicesWithStrides do: [ :pair |
		temp ifNil: [ temp := blockBuilder tacIntRegister ].
		indexValue := (self translateValue: pair first).
		blockBuilder
			tacMultiply: indexValue with: pair second into: temp;
			tacAdd: result with: temp into: result
	].

]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitGetFramePointer: anInstruction [
	| result |
	result := self translateValue: anInstruction.
	blockBuilder tacMove: sasmTarget framePointerRegister into: result
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitGetThisContext: anInstruction [
	| result marryThisContextFunction |
	marryThisContextFunction := target objectModel marryThisContextFunction.
	result := self translateValue: anInstruction.
	blockBuilder tacCall: (self translateValue: marryThisContextFunction)
		arguments: { sasmTarget framePointerRegister }
		into: result convention: (sasmTarget callingConventionNamed: marryThisContextFunction callingConvention)
	
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitIdentityEquals: instruction [
	self binaryInteger: instruction comparison: TacEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitIdentityNotEquals: instruction [
	self binaryInteger: instruction comparison: TacNotEqual
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitInstantiateClosure: anInstruction [
	| result closureFunction definition normalFunctionTypes closureInstantiateFunction capturedEnvironmentType dynamicCaptureCount closureStructureType localEnvironment functionPointerSlot functionPointerOffset captureBaseOffset dynamicCaptureIndex normalCaptureIndex captureIndex captureOffset capturePointer normalFunctionType |
	definition := anInstruction definition.
	self assert: definition isClosureDefinition.

	closureFunction := self translateValue: definition.
	normalFunctionTypes := definition normalFunctionTypes.
	normalFunctionType := normalFunctionTypes first.
	capturedEnvironmentType := normalFunctionTypes second.
	closureStructureType := normalFunctionTypes third.
	
	dynamicCaptureCount := 0.
	capturedEnvironmentType types do: [ :type |
		type isDynamicObjectPointerType ifTrue: [ dynamicCaptureCount := dynamicCaptureCount + 1 ]
	].

	result := self translateValue: anInstruction.
	
	closureInstantiateFunction := target objectModel closureInstantiateFunction.
	closureInstantiateFunction ifNil: [
		"Allocate the closure environment in the stack"
		localEnvironment := sasmFunction newLocal: closureStructureType size alignment: closureStructureType alignment dynamicRoot: false.
		blockBuilder
			tacLoadLocalAddress: localEnvironment into: result.
			
		functionPointerOffset := closureStructureType offsets at: (closureStructureType offsets size - 1).
		functionPointerOffset ~= 0 ifTrue: [
			functionPointerSlot := blockBuilder tacIntRegister.
			blockBuilder tacAdd: result with: 0 into: functionPointerSlot.
		] ifFalse: [
			functionPointerSlot := result
		].
	
		blockBuilder tacStore: closureFunction into: functionPointerSlot.
	] ifNotNil: [ 
		blockBuilder tacCall: (self translateValue: closureInstantiateFunction)
			arguments: {
				closureFunction registers first .
				normalFunctionType argumentsDescriptorWithTarget: target.
				dynamicCaptureCount .
				capturedEnvironmentType size }
			into: result convention: (sasmTarget callingConventionNamed: closureInstantiateFunction callingConvention)
	].
	
	"Load the captures"
	captureBaseOffset := closureStructureType offsets last.
	
	dynamicCaptureIndex := 0.
	normalCaptureIndex := 0.
	anInstruction captures do: [ :cap |
		cap type isDynamicObjectPointerType ifTrue: [ 
			self increaseReferenceOf: cap.
			captureIndex := dynamicCaptureIndex.
			dynamicCaptureIndex := dynamicCaptureIndex + 1
		] ifFalse: [ 
			captureIndex := dynamicCaptureCount + normalCaptureIndex.
			normalCaptureIndex := normalCaptureIndex + 1
		].
	
		captureOffset := captureBaseOffset + (capturedEnvironmentType offsets at: captureIndex + 1).
		captureOffset ~= 0 ifTrue: [ 
			capturePointer := blockBuilder tacIntRegister.
			blockBuilder tacAdd: result with: captureOffset into: capturePointer
		] ifFalse: [ 
			capturePointer := result
		].
	
		self store: cap intoPointerRegister: capturePointer
	].
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitIntToDynamicObjectCast: instruction [
	| source sourceValue result elementSize smallIntegerConstant |
	source := instruction source.
	source isConstantValue ifTrue: [ 
		smallIntegerConstant := (source value << target objectModel smallIntegerShift) | target objectModel smallIntegerTag.
		self flag: 'Ensure the constant value is a small integer'.
		result := self translateValue: instruction.
		^ blockBuilder tacMove: smallIntegerConstant into: result
	].

	sourceValue := self translateValue: source.
	result := self translateValue: instruction.
	self assert: source type isIntegerType.

	self flag: 'Check for overflows'.
	elementSize := source type size.
	source type size < target pointerSize ifTrue: [
		elementSize = 1 ifTrue: [ blockBuilder tacSign: source type isSigned extend8: sourceValue into: result ].
		elementSize = 2 ifTrue: [ blockBuilder tacSign: source type isSigned extend16: sourceValue into: result ].
		elementSize = 4 ifTrue: [ blockBuilder tacSign: source type isSigned extend32: sourceValue into: result ].
		blockBuilder
			tacLogicalShiftLeft: result with: target objectModel smallIntegerShift into: result;
			tacBitOr: result with: target objectModel smallIntegerTag into: result.
	] ifFalse: [
		blockBuilder
			tacLogicalShiftLeft: sourceValue with: target objectModel smallIntegerShift into: result;
			tacBitOr: result with: target objectModel smallIntegerTag into: result.
"		source type size = target pointerSize ifTrue: [ 
			source type isSigned ifTrue: [ 
				self halt.
			] ifFalse: [ 
				self halt.
			].
		] ifFalse: [ 
			source type isSigned ifTrue: [ 
				self halt.
			] ifFalse: [ 
				self halt.
			].
		].
"	].


]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitIntToFloatCast: instruction [
	| result source sourceSize resultSize isSigned |
	result := self translateValue: instruction.
	source := self translateValue: instruction source.
	isSigned := instruction source type isSigned.
	sourceSize := instruction source type size.
	resultSize := instruction type size.
	sourceSize < 4 ifTrue: [
		self halt
	].

	resultSize = 4 ifTrue: [
		sourceSize = 4 ifTrue: [
			isSigned ifTrue: [
				^ blockBuilder tacInt32: source intoFloat: result
			] ifFalse: [ 
				^ blockBuilder tacUInt32: source intoFloat: result
			]
		] ifFalse: [
			target pointerSize = 8 ifTrue: [ 
				isSigned ifTrue: [
					^ blockBuilder tacInt64: source intoFloat: result
				] ifFalse: [ 
					^ blockBuilder tacUInt64: source intoFloat: result
				]
			] ifFalse: [ 
				self halt
			]
		]
	].
	resultSize = 8 ifTrue: [
		sourceSize = 4 ifTrue: [
			isSigned ifTrue: [
				^ blockBuilder tacInt32: source intoDouble: result
			] ifFalse: [ 
				^ blockBuilder tacUInt32: source intoDouble: result
			]
		] ifFalse: [
			self assert: sourceSize = 8.
			target pointerSize = 8 ifTrue: [ 
				isSigned ifTrue: [
					^ blockBuilder tacInt64: source intoDouble: result
				] ifFalse: [ 
					^ blockBuilder tacUInt64: source intoDouble: result
				]
			] ifFalse: [ 
				self halt
			]
		]
	].

	self error: 'Unsupported integer to float cast'.
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitIntegerEqual: instruction [
	self binaryInteger: instruction comparison: TacEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitIntegerGreaterOrEqual: instruction [
	self binaryInteger: instruction comparison: TacGreaterOrEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitIntegerGreaterThan: instruction [
	self binaryInteger: instruction comparison: TacGreater
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitIntegerLessOrEqual: instruction [
	self binaryInteger: instruction comparison: TacLessOrEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitIntegerLessThan: instruction [
	self binaryInteger: instruction comparison: TacLess
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitIntegerNotEqual: instruction [
	self binaryInteger: instruction comparison: TacNotEqual
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitJump: instruction [
	| destination |
	destination := basicBlockMap at: instruction destination.
	blockBuilder tacJump: destination.
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> visitLoad: instruction [
	| result variable |
	(allocaToVariableMap includesKey: instruction variable) ifTrue: [ ^ self ].
	variable := self translateValue: instruction variable.
	self assert: variable isRegisterScalarValue.

	result := self translateValue: instruction.
	self loadFromPointer: variable type: instruction type into: result
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitLogicalNot: instruction [
	self unaryInteger: instruction bitwise: TacLogicalNot
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitMessageSend: instruction [
	| result arguments calledFunction calledConvention selector receiver lookupClass |
	self ensureFunctionContextMetaDataIsPresent.
	
	instruction type isVoidType ifTrue: [
		result := #()
	] ifFalse: [ 
		result := self translateValue: instruction
	].
	arguments := OrderedCollection new.
	
	"Add the selector"
	selector := self translateValue: instruction selector.
	arguments addAll: selector.

	"Add the lookup class"
	instruction isSuperSend ifTrue: [ 
		lookupClass := self translateValue: function dynamicLiterals last.
		arguments addAll: lookupClass.
	].
	
	"Add the receiver"
	receiver := self translateValue: instruction receiver.
	arguments addAll: receiver.
	
	"Add the arguments"
	instruction arguments do: [ :arg | arguments addAll: (self translateValue: arg) ].
	
	
	instruction isSuperSend ifTrue: [ 
		calledFunction := (self runtimeProvidedFunction: target objectModel messageSuperSendTrampoline) asSAsmInstructionOperand.
		calledConvention := sasmTarget callingConventionNamed: #smalltalk_supersend
	] ifFalse: [ 
		calledFunction := (self runtimeProvidedFunction: target objectModel messageSendTrampoline) asSAsmInstructionOperand.
		calledConvention := sasmTarget callingConventionNamed: #smalltalk_send.
	].

	blockBuilder tacCall: calledFunction arguments: arguments into: result convention: calledConvention.

]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitMul: instruction [
	self binaryInteger: instruction arithmetic: TacMultiply
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitNegate: instruction [
	self unaryInteger: instruction arithmetic: TacNegate
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitOrderedFloatEqual: instruction [
	self binaryInteger: instruction comparison: TacFloatOrderedEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitOrderedFloatGreaterOrEqual: instruction [
	self binaryInteger: instruction comparison: TacFloatOrderedGreaterOrEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitOrderedFloatGreaterThan: instruction [
	self binaryInteger: instruction comparison: TacFloatOrderedGreater
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitOrderedFloatLessOrEqual: instruction [
	self binaryInteger: instruction comparison: TacFloatOrderedLessOrEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitOrderedFloatLessThan: instruction [
	self binaryInteger: instruction comparison: TacFloatOrderedLess
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitOrderedFloatNotEqual: instruction [
	self binaryInteger: instruction comparison: TacFloatOrderedNotEqual
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitPointerToDynamicObjectCast: instruction [
	| convertionFunction pointer typeObject result convertionFunctionValue |
	pointer := self translateValue: instruction source.
	typeObject := self translateValue: instruction typeObject.
	result := self translateValue: instruction.
	
	convertionFunction := target objectModel pointerToObjectFunction .
	convertionFunctionValue := self translateValue: convertionFunction.
	blockBuilder tacCall: convertionFunctionValue
		arguments: { pointer registers first . typeObject registers first }
		into: result convention: (sasmTarget callingConventionNamed: convertionFunction callingConvention)
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitRem: instruction [
	self binaryInteger: instruction arithmetic: TacRemainder
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitReturn: instruction [
	| value valueType |
	value := self translateValue: instruction value.
	valueType := instruction value type.
	value isAggregate ifTrue: [
		blockBuilder
			tacCopy: value to: returnArgumentRegister size: valueType size alignment: valueType alignment;
			tacReturn: returnArgumentRegister
	] ifFalse: [ 
		value size > 1 ifTrue: [ 
			self halt.
		] ifFalse: [
			blockBuilder tacReturn: value
		]
	]
	
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitReturnFromContext: instruction [
	| value valueType context nonLocalReturnFunction |
	value := self translateValue: instruction value.
	context := self translateValue: instruction context.
	valueType := instruction value type.
	value isAggregate ifTrue: [
		self halt.
	].

	valueType isScalarType ifTrue: [ 
		valueType isScalarIntegerType ifTrue: [ 
			value size > 1 ifTrue: [ 
				self halt.
			] ifFalse: [
				nonLocalReturnFunction := target objectModel nonLocalReturnFunction.
				^ blockBuilder tacCall: (self translateValue: nonLocalReturnFunction) 
					arguments: { context . value }
					into: #() convention: (sasmTarget callingConventionNamed: nonLocalReturnFunction callingConvention).
			].
		].
		valueType isFloatType  ifTrue: [ 
			self halt.
		].
	].

	self error: 'Unsupported value type for non-local return'
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitReturnVoid: instruction [
	blockBuilder tacReturnVoid
	
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitRotateLeft: instruction [
	self binaryInteger: instruction bitwise: TacRotateLeft
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitRotateRight: instruction [
	self binaryInteger: instruction bitwise: TacRotateRight
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitShiftLeft: instruction [
	self binaryInteger: instruction bitwise: TacLogicalShiftLeft
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitShiftRight: instruction [
	self binaryInteger: instruction bitwise: TacLogicalShiftRight
]

{ #category : #'bitwise operations' }
SLVMSAsmFunctionCodeGenerator >> visitShiftRightArithmetic: instruction [
	self binaryInteger: instruction bitwise: TacArithmeticShiftRight
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitSignExtend: instruction [
	| source sourceValue result elementSize |
	source := instruction source.
	sourceValue := self translateValue: source.
	result := self translateValue: instruction.
	self assert: source type isIntegerType.
	elementSize := source type size.
	elementSize = 1 ifTrue: [ blockBuilder tacSignExtend8: sourceValue into: result ].
	elementSize = 2 ifTrue: [ blockBuilder tacSignExtend16: sourceValue into: result ].
	elementSize = 4 ifTrue: [ blockBuilder tacSignExtend32: sourceValue into: result ].
	result size > 1 ifTrue: [ 
		self assert: result size = 2.
		self halt
	]
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> visitStore: instruction [
	| variable |
	allocaToVariableMap at: instruction variable ifPresent: [ :allocatedVariable |
		^ self move: (self translateValue: instruction value) into: allocatedVariable
	].

	"instruction variable isAlloca ifTrue: [ self halt ]."
	variable := self translateValue: instruction variable.
	self assert: variable isRegisterScalarValue.
	self store: instruction value intoPointerRegister: variable.

]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitSub: instruction [
	self binaryInteger: instruction arithmetic: TacSubtract
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitTruncate: instruction [
	| source sourceValue result elementSize |
	source := instruction source.
	sourceValue := self translateValue: source.
	result := self translateValue: instruction.
	self assert: source type isIntegerType.
	elementSize := instruction type size.
	elementSize = 1 ifTrue: [ blockBuilder tacSignExtend8: sourceValue into: result ].
	elementSize = 2 ifTrue: [ blockBuilder tacSignExtend16: sourceValue into: result ].
	elementSize = 4 ifTrue: [ blockBuilder tacSignExtend32: sourceValue into: result ].

]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitUDiv: instruction [
	self binaryInteger: instruction arithmetic: TacUDivide
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitURem: instruction [
	self binaryInteger: instruction arithmetic: TacURemainder
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitUnaryOperation: instruction [
	| selector |
	selector := OperationCodeGeneratorMap at: instruction operation.
	^ self perform: selector with: instruction

]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnorderedFloatEqual: instruction [
	self binaryInteger: instruction comparison: TacFloatUnorderedEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnorderedFloatGreaterOrEqual: instruction [
	self binaryInteger: instruction comparison: TacFloatUnorderedGreaterOrEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnorderedFloatGreaterThan: instruction [
	self binaryInteger: instruction comparison: TacFloatUnorderedGreater
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnorderedFloatLessOrEqual: instruction [
	self binaryInteger: instruction comparison: TacFloatUnorderedLessOrEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnorderedFloatLessThan: instruction [
	self binaryInteger: instruction comparison: TacFloatUnorderedLess
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnorderedFloatNotEqual: instruction [
	self binaryInteger: instruction comparison: TacFloatUnorderedNotEqual
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitUnreachable: aNode [
	self flag: 'Emit debugger trap'.
	
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnsignedIntegerGreaterOrEqual: instruction [
	self binaryInteger: instruction comparison: TacAboveOrEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnsignedIntegerGreaterThan: instruction [
	self binaryInteger: instruction comparison: TacAbove
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnsignedIntegerLessOrEqual: instruction [
	self binaryInteger: instruction comparison: TacBelowOrEqual
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> visitUnsignedIntegerLessThan: instruction [
	self binaryInteger: instruction comparison: TacBelow
]

{ #category : #casting }
SLVMSAsmFunctionCodeGenerator >> visitZeroExtend: instruction [
	| source sourceValue result elementSize |
	source := instruction source.
	sourceValue := self translateValue: source.
	result := self translateValue: instruction.
	self assert: source type isIntegerType.
	elementSize := source type size.
	elementSize = 1 ifTrue: [ blockBuilder tacZeroExtend8: sourceValue into: result ].
	elementSize = 2 ifTrue: [ blockBuilder tacZeroExtend16: sourceValue into: result ].
	elementSize = 4 ifTrue: [ blockBuilder tacZeroExtend32: sourceValue into: result ].
	result size > 1 ifTrue: [ 
		self assert: result size = 2.
		blockBuilder tacMove: 0 into: result second.
	]
]
