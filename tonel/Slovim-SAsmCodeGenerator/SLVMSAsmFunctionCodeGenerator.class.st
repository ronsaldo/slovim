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
		'constantTranslator'
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

{ #category : #visiting }
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

{ #category : #visiting }
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

	function basicBlocks do: [ :basicBlock |
		basicBlock instructionsDo: [ :instruction |
			type := instruction type.
			type isVoidType ifFalse: [ 
				valueVariableMap at: instruction put: (self createVirtualRegistersForType: type).
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

{ #category : #accessing }
SLVMSAsmFunctionCodeGenerator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMSAsmFunctionCodeGenerator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #'code generation' }
SLVMSAsmFunctionCodeGenerator >> postProcessCodeGeneration [
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
	result := self translateValue: instruction.
	calledFunction := self translateValue: instruction functionValue.
	arguments := OrderedCollection new.
	instruction arguments do: [ :arg | arguments addAll: (self translateValue: arg) ].
	calledConvention := sasmTarget callingConventionNamed: instruction callingConvention.
	self assert: calledFunction size = 1.
	blockBuilder tacCall: calledFunction first arguments: arguments into: result convention: calledConvention.
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitIntegerEqual: instruction [
	self binaryInteger: instruction comparison: TacEqual
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitIntegerGreaterOrEqual: instruction [
	self binaryInteger: instruction comparison: TacGreaterOrEqual
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitIntegerGreaterThan: instruction [
	self binaryInteger: instruction comparison: TacGreater
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitIntegerLessOrEqual: instruction [
	self binaryInteger: instruction comparison: TacLessOrEqual
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitIntegerLessThan: instruction [
	self binaryInteger: instruction comparison: TacLess
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitIntegerNotEqual: instruction [
	self binaryInteger: instruction comparison: TacNotEqual
]

{ #category : #visiting }
SLVMSAsmFunctionCodeGenerator >> visitJump: instruction [
	| destination |
	destination := basicBlockMap at: instruction destination.
	blockBuilder tacJump: destination.
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
