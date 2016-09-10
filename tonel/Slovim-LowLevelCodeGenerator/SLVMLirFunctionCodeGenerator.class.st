Class {
	#name : #SLVMLirFunctionCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'registerAllocator',
		'lirFunction',
		'function',
		'basicBlockDictionary',
		'currentBlockTarget',
		'compilationTarget',
		'codeGenerator',
		'constantBlock',
		'constantZoneDictionary',
		'moduleTranslator'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #adding }
SLVMLirFunctionCodeGenerator >> addLabel: aLabel [
	currentBlockTarget addInstruction: aLabel
]

{ #category : #'register allocation' }
SLVMLirFunctionCodeGenerator >> allocateInstructionResultRegister: instruction [
	^ registerAllocator allocateInstructionResultRegister: instruction
]

{ #category : #accessing }
SLVMLirFunctionCodeGenerator >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirFunctionCodeGenerator >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> createArguments [
	| stackFrame argVariable type size alignment |
	stackFrame := lirFunction stackFrame.
	function arguments do: [ :arg |
		type := arg type.
		size := type size.
		alignment := type alignment max: self stackElementGranularity.
		argVariable := stackFrame createArgument: size alignment: alignment.
		lirFunction mapSSA: arg toStackVariable: argVariable 
	]
]

{ #category : #'register allocation' }
SLVMLirFunctionCodeGenerator >> ensureInstruction: instruction valueInMemory: value [
	^ registerAllocator moveInstruction: instruction value: value toMemoryWith: self
]

{ #category : #'register allocation' }
SLVMLirFunctionCodeGenerator >> ensureInstruction: instruction valueInRegister: value [
	^ registerAllocator moveInstruction: instruction value: value toRegisterWith: self
]

{ #category : #'register allocation' }
SLVMLirFunctionCodeGenerator >> ensureInstruction: instruction valueInRegisterForPushing: value [
	^ registerAllocator moveInstruction: instruction value: value toRegisterForPushingWith: self
]

{ #category : #'register allocation' }
SLVMLirFunctionCodeGenerator >> ensureInstruction: instruction valueInRegisterOrLocalForPushing: value [
	^ registerAllocator moveInstruction: instruction value: value toRegisterOrLocalForPushingWith: self
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> generateFunction: aFunction [
	^ self generateFunction: aFunction into: (SLVMLirFunction new compilationTarget: compilationTarget).


]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> generateFunction: aFunction into: aLirFunction [
	aFunction isEmpty ifTrue: [ ^ aLirFunction ].
	
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
SLVMLirFunctionCodeGenerator >> initialize [
	super initialize.
	registerAllocator := SLVMGreedyRegisterAllocator new.
	compilationTarget := SLVM32BitsPointerCompilationTarget new.
	constantZoneDictionary := Dictionary new.
]

{ #category : #'register allocation' }
SLVMLirFunctionCodeGenerator >> instruction: instruction resultInRegister: register [
	registerAllocator moveInstruction: instruction resultInRegister: register with: self
]

{ #category : #accessing }
SLVMLirFunctionCodeGenerator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMLirFunctionCodeGenerator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> moveConstant: value toRegisterLow: registerLow high: registerHigh [
	self subclassResponsibility
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> moveRegister: register toLocal: localVariable [
	self subclassResponsibility
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> moveValue: value toRegister: register [
	value isConstant ifTrue: [
		self moveConstant: value toRegister: register
	] ifFalse: [
		registerAllocator moveInstruction: value toRegister: register with: self
	]
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> moveValue: value toRegisterLow: registerLow high: registerHigh [
	value isConstant ifTrue: [
		self moveConstant: value toRegisterLow: registerLow high: registerHigh
	] ifFalse: [
		registerAllocator moveInstruction: value toRegisterLow: registerLow high: registerHigh with: self
	]
]

{ #category : #adding }
SLVMLirFunctionCodeGenerator >> newLabel: name [
	^ SLVMLirLabel new name: name
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> postProcessCodeGeneration [
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> putConstantInConstantZone: aConstant [
	| label |
	^ constantZoneDictionary at: aConstant ifAbsentPut: [
		label := SLVMLirLabel new name: #constant.
		constantBlock addInstruction: label.
		aConstant writeToLirBlock: constantBlock withLabel: label withGenerator: self.
		label
	]
	
]

{ #category : #accessing }
SLVMLirFunctionCodeGenerator >> registerAllocator [
	^ registerAllocator
]

{ #category : #accessing }
SLVMLirFunctionCodeGenerator >> registerAllocator: anObject [
	registerAllocator := anObject
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> stackElementGranularity [
	^ 4
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> translateBasicBlock: basicBlock [
	self translateBasicBlock: basicBlock into: (basicBlockDictionary at: basicBlock)
]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> translateBasicBlock: basicBlock into: lirBasicBlock [
	currentBlockTarget := lirBasicBlock.
	self translateBasicBlockInstructions: basicBlock

]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> translateBasicBlockInstructions: basicBlock [
	basicBlock instructionsDo: [ :ins |
		ins accept: self
	].

]

{ #category : #'code generation' }
SLVMLirFunctionCodeGenerator >> translateBasicBlocks [
	"Create the new basic blocks"
	| lirBlock |
	basicBlockDictionary := Dictionary new.
	function basicBlocks do: [ :bb |
		lirBlock := SLVMLirBasicBlock new name: bb name asSymbol.
		lirFunction addBasicBlock: lirBlock.
		basicBlockDictionary at: bb put: lirBlock.
	].
	constantBlock := SLVMLirBasicBlock new 
		name: #constantZone;
		sectionName: #'.rodata';
		yourself.
	lirFunction addBasicBlock: constantBlock.

	registerAllocator translateBasicBlocks: function basicBlocks with: self.

]
