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
		'allocaToVariableMap'
	],
	#classVars : [
		'OperationCodeGeneratorMap'
	],
	#pools : [
		'SAsmTacOperations'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #'class initialization' }
SLVMSAsmFunctionCodeGenerator class >> initialize [
	OperationCodeGeneratorMap := IdentityDictionary newFromPairs: #(
		add visitAdd:
		sub visitSub:
		mul visitMul:
		div visitDiv:
		udiv visitUDiv:
		rem visitRem:
		urem visitURem:
		
		bitand visitBitAnd:
		bitor visitBitOr:
		bitxor visitBitXor:
		
		shiftleft visitShiftLeft:
		shiftright visitShiftRight:
		shiftrightarithmetic visitShiftRightArithmetic:
		
		fadd visitFloatAdd:
		fsub visitFloatSub:
		fmul visitFloatMul:
		fdiv visitFloatDiv:
		
		ilt visitIntegerLessThan:
		ile visitIntegerLessOrEqual:
		ieq visitIntegerEqual:
		ine visitIntegerNotEqual:
		igt visitIntegerGreaterThan:
		ige visitIntegerGreaterOrEqual:

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
		dynObjectIdentityEquals visitIdentityNotEquals:
		
		mulMatrixMatrix visitMultiplyMatrixWithMatrix:
		mulMatrixVector visitMultiplyMatrixWithVector:
		mulVectorMatrix visitMultiplyVectorWithMatrix:
	).
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
	
	^ blockBuilder tacOperation: operation result: resultValue first left: leftValue first right: rightValue first
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> binaryInteger: instruction comparison: comparison [
	| left right result type |
	left := self translateValue: instruction left.
	right := self translateValue: instruction right.
	result := self translateValue: instruction.
	type := instruction type.
	self assert: left isArray.
	self assert: right isArray.
	self assert: result isArray.
	self assert: left size = right size.
	type isBooleanType ifTrue: [ 
		self assert: result size = 1.
		self compare: comparison integer: left with: right into: result first.
	] ifFalse: [
		self assert: result size >= left size.
		result size > left size ifTrue: [ 
			self halt
		] ifFalse: [ 
			1 to: result size do: [ :i |
				self compare: comparison integer: (left at: i) with: (right at: i) into: (result at: i).
			]
		]
	]
]

{ #category : #comparisons }
SLVMSAsmFunctionCodeGenerator >> compare: comparison integer: left with: right into: result [
	left size == 1 ifTrue: [ 
		blockBuilder tacOperation: comparison result: result left: left first right: right first
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
	function basicBlocks first allocaInstructionsDo: [ :alloca |
		alloca isOnlyUsedByLoadStore ifTrue: [
			registers := self createVirtualRegistersForType: alloca valueType.
			allocaToVariableMap at: alloca put: registers.
			alloca instructionReferences do: [ :ref |
				ref isLoad ifTrue: [ valueVariableMap at: ref put: registers ].
			]
		]
	]
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createArguments [
	| stackFrameLayout |
	stackFrameLayout := sasmFunction stackFrameLayout.
	argumentVariableMap := Dictionary new.
	
	function arguments do: [ :arg |
		argumentVariableMap at: arg put: (stackFrameLayout createArgument: arg type spillingClass).
	]
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
			type := instruction type.
			type isVoidType ifFalse: [ 
				valueVariableMap at: instruction ifAbsentPut: [self createVirtualRegistersForType: type].
			]
		]
	].



]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createVirtualRegistersForType: type [
	type isScalarType ifTrue: [ 
		type isScalarIntegerType ifTrue: [
			^ sasmFunction addVirtualRegisters: (sasmTarget newIntegerVirtualRegistersForSize: type size)
		].
		type isFloatType ifTrue: [
			^ sasmFunction addVirtualRegisters: (sasmTarget newFloatVirtualRegistersForSize: type size)
		].
	].

	type isVectorType ifTrue: [ 
		self halt.
	].

	^ sasmFunction stackFrameLayout createLocal: type spillingClass

]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> createVirtualRegistersForVariable: variable type: type [
	| registers |
	registers := self createVirtualRegistersForType: type.
	registers isArray ifFalse: [ ^ registers ].
	
	registers doWithIndex: [ :reg :index |
		reg
			variable: variable;
			variableOffset: (index - 1) * reg size
	].
	^ registers
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> generateFunction: slvmFunction into: newSasmFunction [
	slvmFunction isEmpty ifTrue: [ ^ newSasmFunction ].
	
	function := slvmFunction.
	function dominanceTopoSort.
	sasmFunction := newSasmFunction.
	sasmFunction callingConventionNamed: function callingConvention.
	self
		createArguments;
		createVirtualRegisters;
		translateBasicBlocks;
		postProcessCodeGeneration
	
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> loadFrom: pointer scalarType: type into: result [
	| temp |
	self assert: type isScalarType.
	
	(type isPointerType or: [ type isDynamicObjectType ]) ifTrue: [
		self assert: result size = 1.
		^ blockBuilder tacLoad: pointer into: result first
	].
	type isFloatType ifTrue: [
		self assert: result size = 1.
		type size = 4 ifTrue: [ 
			^ blockBuilder tacLoadFloat: pointer into: result first
		].
		type size = 8 ifTrue: [ 
			^ blockBuilder tacLoadDouble: pointer into: result first
		].
		self halt
	].

	type isBooleanType ifTrue: [
		^ blockBuilder tacLoadZeroExtend8: pointer into: result first
	].

	type isIntegerType ifTrue: [
		type size <= 4 ifTrue: [ 
			self assert: result size = 1.
			type isSigned ifTrue: [
				type size = 1 ifTrue: [ ^ blockBuilder tacLoadSignExtend8: pointer into: result first ].
				type size = 2 ifTrue: [ ^ blockBuilder tacLoadSignExtend16: pointer into: result first ].
				type size = 4 ifTrue: [ ^ blockBuilder tacLoadSignExtend32: pointer into: result first ].
			] ifFalse: [ 
				type size = 1 ifTrue: [ ^ blockBuilder tacLoadZeroExtend8: pointer into: result first ].
				type size = 2 ifTrue: [ ^ blockBuilder tacLoadZeroExtend16: pointer into: result first ].
				type size = 4 ifTrue: [ ^ blockBuilder tacLoadZeroExtend32: pointer into: result first ].
			].
		
			self error: 'Unsupported integer type.'
		].
	
		self assert: type size = 8.
		result size = 1 ifTrue: [ 
			^ blockBuilder tacLoad: pointer into: result first.
		] ifFalse: [ 
			self assert: result size = 2.
			temp := blockBuilder tacIntRegister.
			sasmTarget isLittleEndian ifTrue: [ 
				^ blockBuilder
					tacLoad: pointer into: result first;
					tacAdd: pointer with: 4 into: temp;
					tacLoad: temp into: result second
			] ifFalse: [ 
				^ blockBuilder
					tacLoad: pointer into: result second;
					tacAdd: pointer with: 4 into: temp;
					tacLoad: temp into: result first
			]
		]
	].

	self error: 'Unsupported scalar type loading.'.
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
	self assert: sourceValue isArray = targetValue isArray.
	sourceValue isArray ifTrue: [ 
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

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> store: value scalarType: type into: pointer [
	| temp |
	self assert: type isScalarType.
	(type isPointerType or: [ type isDynamicObjectType ]) ifTrue: [
		self assert: value size = 1.
		^ blockBuilder tacStore: value first into: pointer.
	].
	type isFloatType ifTrue: [
		self assert: value size = 1.
		type size = 4 ifTrue: [
			^ blockBuilder tacStoreFloat: value first into: pointer
		].
		type size = 8 ifTrue: [
			^ blockBuilder tacStoreDouble: value first into: pointer
		].
		self halt
	].

	type isBooleanType ifTrue: [
		^ blockBuilder tacStoreTruncate8: value first into: pointer
	].

	type isIntegerType ifTrue: [
		type size <= 4 ifTrue: [ 
			self assert: value size = 1.
			type size = 1 ifTrue: [ ^ blockBuilder tacStoreTruncate8: value first into: pointer ].
			type size = 2 ifTrue: [ ^ blockBuilder tacStoreTruncate16: value first into: pointer ].
			type size = 4 ifTrue: [ ^ blockBuilder tacStoreTruncate32: value first into: pointer ].
		
			self error: 'Unsupported integer type.'
		].
	
		self assert: type size = 8.
		value size = 1 ifTrue: [ 
			^ blockBuilder tacStore: value into: pointer
		] ifFalse: [ 
			self assert: value size = 2.
			temp := blockBuilder tacIntRegister.
			sasmTarget isLittleEndian ifTrue: [
				^ blockBuilder
					tacStore: value first into: pointer;
					tacAdd: pointer with: 4 into: temp;
					tacStore: value second into: pointer
			] ifFalse: [
				^ blockBuilder
					tacStore: value second into: pointer;
					tacAdd: pointer with: 4 into: temp;
					tacStore: value first into: pointer
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
	basicBlock instructionsDo: [ :instruction |
		instruction accept: self
	]
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> translateBasicBlocks [
	| lowBasicBlock |
	basicBlockMap := Dictionary new.
	function basicBlocks do: [ :bb |
		lowBasicBlock := SAsmBasicBlock new name: bb name.
		sasmFunction addBasicBlock: lowBasicBlock.
		basicBlockMap at: bb put: lowBasicBlock
	].

	function basicBlocks do: [ :bb |
		lowBasicBlock := basicBlockMap at: bb.
		lowBasicBlock build: [ :builder |
			blockBuilder := builder.
			self translateBasicBlock: bb
		]
	].
	
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> translateConstant: value [
	^ self constantTranslator translate: value
	
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> translateValue: value [
	value isConstant ifTrue: [ ^ self translateConstant: value ].
	(value isFunctionArgument or: [ value isInstruction ]) ifTrue: [ ^ valueVariableMap at: value ].

	self halt.
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitAdd: instruction [
	self binaryInteger: instruction arithmetic: TacAdd
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitAlloca: instruction [
	(allocaToVariableMap includesKey: instruction) ifTrue: [ ^ self ].
	self halt.
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitBinaryOperation: instruction [
	| selector |
	selector := OperationCodeGeneratorMap at: instruction operation.
	^ self perform: selector with: instruction

]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitBranch: instruction [
	| condition trueDestination falseDestination |
	condition := self translateValue: instruction condition.
	self assert: condition size = 1.
	trueDestination := basicBlockMap at: instruction trueBlock.
	falseDestination := basicBlockMap at: instruction falseBlock.
	blockBuilder tacBranch: condition first true: trueDestination false: falseDestination.
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitCall: instruction [
	| calledFunction arguments result calledConvention |
	instruction type isVoidType ifTrue: [
		result := #()
	] ifFalse: [ 
		result := self translateValue: instruction
	].
	calledFunction := self translateValue: instruction functionValue.
	arguments := OrderedCollection new.
	instruction arguments do: [ :arg | arguments addAll: (self translateValue: arg) ].
	calledConvention := sasmTarget callingConventionNamed: instruction callingConvention.
	self assert: calledFunction size = 1.
	blockBuilder tacCall: calledFunction first arguments: arguments into: result convention: calledConvention.
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitDiv: instruction [
	self binaryInteger: instruction arithmetic: TacDivide
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitGetElementPointer: instruction [
	| constantDisplacement indicesWithStrides indices strides index stride pointer result indexValue temp |
	constantDisplacement := 0.
	indicesWithStrides := OrderedCollection new.
	
	indices := instruction indices.
	strides := instruction strides.
	1 to: indices size do: [ :i |
		index := indices at: i.
		stride := strides at: i.
		index isConstantValue ifTrue: [ 
			constantDisplacement := constantDisplacement + (index value * stride)
		] ifFalse: [
			indicesWithStrides add: { index . stride }
		]
	].

	"Get the pointer. It should always fit in a single register."
	pointer := self translateValue: instruction pointer.
	self assert: pointer size = 1.
	pointer := pointer first.
	
	result := self translateValue: instruction.
	self assert: result size = 1.
	result := result first.
	constantDisplacement ~= 0 ifTrue: [ 
		blockBuilder tacAdd: pointer with: constantDisplacement into: result
	] ifFalse: [
		blockBuilder tacMove: pointer into: result
	].

	temp := nil.
	indicesWithStrides do: [ :pair |
		temp ifNil: [ temp := blockBuilder tacIntRegister ].
		indexValue := (self translateValue: pair first) first.
		blockBuilder
			tacMultiply: indexValue with: pair second into: temp;
			tacAdd: result with: temp into: result
	].

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
	| result variable type |
	(allocaToVariableMap includesKey: instruction variable) ifTrue: [ ^ self ].
	variable := self translateValue: instruction variable.
	self assert: variable size = 1.
	variable := variable first.

	result := self translateValue: instruction.
	type := instruction type.
	type isScalarType ifTrue: [
		^ self loadFrom: variable scalarType: type into: result
	].

	"Aggregate type. We have to copy."

	self halt.
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitMul: instruction [
	self binaryInteger: instruction arithmetic: TacMultiply
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitRem: instruction [
	self binaryInteger: instruction arithmetic: TacRemainder
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitReturn: instruction [
	| value |
	value := self translateValue: instruction value.
	value size > 1 ifTrue: [ 
		self halt.
	] ifFalse: [
		blockBuilder tacReturn: value first
	]
	
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitReturnVoid: instruction [
	blockBuilder tacReturnVoid
	
]

{ #category : #memory }
SLVMSAsmFunctionCodeGenerator >> visitStore: instruction [
	| variable value type |
	allocaToVariableMap at: instruction variable ifPresent: [ :allocatedVariable |
		^ self move: (self translateValue: instruction value) into: allocatedVariable
	].

	variable := self translateValue: instruction variable.
	self assert: variable size = 1.
	variable := variable first.
	
	value := self translateValue: instruction value.
	type := instruction value type.

	type isScalarType ifTrue: [
		^ self store: value scalarType: type into: variable
	].

	"Aggregate type. We have to copy."

	self halt.
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitSub: instruction [
	self binaryInteger: instruction arithmetic: TacSubtract
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitUDiv: instruction [
	self binaryInteger: instruction arithmetic: TacUDivide
]

{ #category : #arithmetic }
SLVMSAsmFunctionCodeGenerator >> visitURem: instruction [
	self binaryInteger: instruction arithmetic: TacURemainder
]
