Class {
	#name : #SLVMLirFunctionGenerator,
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

{ #category : #adding }
SLVMLirFunctionGenerator >> addLabel: aLabel [
	currentBlockTarget addInstruction: aLabel
]

{ #category : #'as yet unclassified' }
SLVMLirFunctionGenerator >> allocateInstructionResultRegister: instruction [
	^ registerAllocator allocateInstructionResultRegister: instruction
]

{ #category : #accessing }
SLVMLirFunctionGenerator >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirFunctionGenerator >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> createArguments [
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
SLVMLirFunctionGenerator >> generateFunction: aFunction [
	^ self generateFunction: aFunction into: (SLVMLirFunction new compilationTarget: compilationTarget).


]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> generateFunction: aFunction into: aLirFunction [
	function := aFunction.
	function dominanceTopoSort.
	lirFunction := aLirFunction.
	registerAllocator function: aFunction; lirFunction: lirFunction; allocateRegisters.
	self
		createArguments;
		translateBasicBlocks;
		postProcessCodeGeneration.
	^ lirFunction

]

{ #category : #initialization }
SLVMLirFunctionGenerator >> initialize [
	super initialize.
	registerAllocator := SLVMGreedyRegisterAllocator new.
	compilationTarget := SLVM32BitsPointerCompilationTarget new.
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> instruction: instruction resultInRegister: register [
	registerAllocator moveInstruction: instruction resultInRegister: register with: self
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> moveConstant: value toRegisterLow: registerLow high: registerHigh [
	self subclassResponsibility
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> moveRegister: register toLocal: localVariable [
	self subclassResponsibility
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> moveValue: value toRegister: register [
	value isConstant ifTrue: [
		self moveConstant: value toRegister: register
	] ifFalse: [
		registerAllocator moveInstruction: value toRegister: register with: self
	]
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> moveValue: value toRegisterLow: registerLow high: registerHigh [
	value isConstant ifTrue: [
		self moveConstant: value toRegisterLow: registerLow high: registerHigh
	] ifFalse: [
		registerAllocator moveInstruction: value toRegisterLow: registerLow high: registerHigh with: self
	]
]

{ #category : #adding }
SLVMLirFunctionGenerator >> newLabel: name [
	^ SLVMLirLabel new name: name
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> postProcessCodeGeneration [
]

{ #category : #accessing }
SLVMLirFunctionGenerator >> registerAllocator [
	^ registerAllocator
]

{ #category : #accessing }
SLVMLirFunctionGenerator >> registerAllocator: anObject [
	registerAllocator := anObject
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> stackElementGranularity [
	^ 4
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> translateBasicBlock: basicBlock [
	self translateBasicBlock: basicBlock into: (basicBlockDictionary at: basicBlock)
]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> translateBasicBlock: basicBlock into: lirBasicBlock [
	currentBlockTarget := lirBasicBlock.
	self translateBasicBlockInstructions: basicBlock

]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> translateBasicBlockInstructions: basicBlock [
	basicBlock instructionsDo: [ :ins |
		ins accept: self
	].

]

{ #category : #'code generation' }
SLVMLirFunctionGenerator >> translateBasicBlocks [
	"Create the new basic blocks"
	| lirBlock |
	basicBlockDictionary := Dictionary new.
	function basicBlocks do: [ :bb |
		lirBlock := SLVMLirBasicBlock new name: bb name asSymbol.
		lirFunction addBasicBlock: lirBlock.
		basicBlockDictionary at: bb put: lirBlock.
	].

	registerAllocator translateBasicBlocks: function basicBlocks with: self.

]
