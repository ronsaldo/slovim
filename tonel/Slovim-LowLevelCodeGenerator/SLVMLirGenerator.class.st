Class {
	#name : #SLVMLirGenerator,
	#superclass : #Object,
	#instVars : [
		'registerAllocator',
		'lirFunction',
		'function',
		'basicBlockDictionary',
		'currentBlockTarget',
		'compilationTarget',
		'codeGenerator'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'code generation' }
SLVMLirGenerator class >> generateFunction: aFunction [
	^ self new generateFunction: aFunction
]

{ #category : #adding }
SLVMLirGenerator >> addLabel: aLabel [
	currentBlockTarget addInstruction: aLabel
]

{ #category : #'as yet unclassified' }
SLVMLirGenerator >> allocateInstructionResultRegister: instruction [
	^ registerAllocator allocateInstructionResultRegister: instruction
]

{ #category : #accessing }
SLVMLirGenerator >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirGenerator >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #'code generation' }
SLVMLirGenerator >> createArguments [
	| stackFrame argVariable type size alignment |
	stackFrame := lirFunction stackFrame.
	function arguments do: [ :arg |
		type := arg type.
		size := type sizeForTarget: compilationTarget.
		alignment := (type alignmentForTarget: compilationTarget) max: self stackElementGranularity.
		argVariable := stackFrame createArgument: size alignment: alignment.
		lirFunction mapSSA: arg toStackVariable: argVariable 
	]
]

{ #category : #'code generation' }
SLVMLirGenerator >> generateFunction: aFunction [
	function := aFunction.
	function dominanceTopoSort.
	lirFunction := SLVMLirFunction new compilationTarget: compilationTarget.
	registerAllocator function: aFunction; lirFunction: lirFunction; allocateRegisters.
	self
		createArguments;
		translateBasicBlocks;
		postProcessCodeGeneration.
	^ lirFunction

]

{ #category : #initialization }
SLVMLirGenerator >> initialize [
	super initialize.
	registerAllocator := SLVMGreedyRegisterAllocator new.
	compilationTarget := SLVM32BitsPointerCompilationTarget new.
]

{ #category : #'code generation' }
SLVMLirGenerator >> instruction: instruction resultInRegister: register [
	registerAllocator moveInstruction: instruction resultInRegister: register with: self
]

{ #category : #'code generation' }
SLVMLirGenerator >> moveConstant: value toRegisterLow: registerLow high: registerHigh [
	self subclassResponsibility
]

{ #category : #'code generation' }
SLVMLirGenerator >> moveRegister: register toLocal: localVariable [
	self subclassResponsibility
]

{ #category : #'code generation' }
SLVMLirGenerator >> moveValue: value toRegister: register [
	value isConstant ifTrue: [
		self moveConstant: value toRegister: register
	] ifFalse: [
		registerAllocator moveInstruction: value toRegister: register with: self
	]
]

{ #category : #'code generation' }
SLVMLirGenerator >> moveValue: value toRegisterLow: registerLow high: registerHigh [
	value isConstant ifTrue: [
		self moveConstant: value toRegisterLow: registerLow high: registerHigh
	] ifFalse: [
		registerAllocator moveInstruction: value toRegisterLow: registerLow high: registerHigh with: self
	]
]

{ #category : #adding }
SLVMLirGenerator >> newLabel: name [
	^ SLVMLirLabel new name: name
]

{ #category : #'code generation' }
SLVMLirGenerator >> postProcessCodeGeneration [
]

{ #category : #accessing }
SLVMLirGenerator >> registerAllocator [
	^ registerAllocator
]

{ #category : #accessing }
SLVMLirGenerator >> registerAllocator: anObject [
	registerAllocator := anObject
]

{ #category : #'code generation' }
SLVMLirGenerator >> stackElementGranularity [
	^ 4
]

{ #category : #'code generation' }
SLVMLirGenerator >> translateBasicBlock: basicBlock [
	self translateBasicBlock: basicBlock into: (basicBlockDictionary at: basicBlock)
]

{ #category : #'code generation' }
SLVMLirGenerator >> translateBasicBlock: basicBlock into: lirBasicBlock [
	currentBlockTarget := lirBasicBlock.
	basicBlock instructionsDo: [ :ins |
		ins accept: self
	].

]

{ #category : #'code generation' }
SLVMLirGenerator >> translateBasicBlocks [
	"Create the new basic blocks"
	| lirBlock |
	basicBlockDictionary := Dictionary new.
	function basicBlocks do: [ :bb |
		lirBlock := SLVMLirBasicBlock new name: bb name.
		lirFunction addBasicBlock: lirBlock.
		basicBlockDictionary at: bb put: lirBlock.
	].

	registerAllocator translateBasicBlocks: function basicBlocks with: self.

]
