Class {
	#name : #SLVMLirX86CodeGenerator,
	#superclass : #SLVMLirGenerator,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #instructions }
SLVMLirX86CodeGenerator >> addX86: opcode [
	^ self addX86: opcode operands: #()
]

{ #category : #instructions }
SLVMLirX86CodeGenerator >> addX86: opcode operands: operands [
	currentBlockTarget addInstruction: (SLVMLirX86Instruction new opcode: opcode; operands: operands); yourself
]

{ #category : #instructions }
SLVMLirX86CodeGenerator >> addX86: opcode with: operand [
	^ self addX86: opcode operands: {operand asLirInstructionOperand}
]

{ #category : #instructions }
SLVMLirX86CodeGenerator >> addX86: opcode with: op1 with: op2 [
	^ self addX86: opcode operands: {op1 asLirInstructionOperand . op2 asLirInstructionOperand}
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> ensureInstruction: instruction valueInRegister: value [
	^ registerAllocator moveInstruction: instruction value: value toRegisterWith: self
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> ensureInstructionValuesInRegistersOrImmediate: instruction [
	| first second |
	self assert: instruction parameters size = 2.
	first := instruction parameters first.
	second := instruction parameters second.
	
	(first isConstant and: [ second isConstant ]) ifTrue: [ 
		self halt.
	].

	first isConstant ifTrue: [ ^ { first . self ensureInstruction: instruction valueInRegister: second } ].
	second isConstant ifTrue: [ ^ { self ensureInstruction: instruction valueInRegister: first . second } ].
	^ { self ensureInstruction: instruction valueInRegister: first . self ensureInstruction: instruction valueInRegister: second }
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> generatePrologue [
	| prologueBlock stackFrame entryBlock |	
	entryBlock := lirFunction basicBlocks first.
	prologueBlock := SLVMLirBasicBlock new.
	prologueBlock name: #prologue.
	lirFunction addFirstBasicBlock: prologueBlock.
	
	currentBlockTarget := prologueBlock.

	"Create the stack frame"
	self
		addX86: PUSH with: EBP;
		addX86: MOV with: EBP with: ESP.
	
	"Allocate space for the variables"
	stackFrame := lirFunction stackFrame.
	stackFrame optimizeAndBuildLayout.
	stackFrame size ~= 0 ifTrue: [
		self addX86: SUB with: ESP with: (stackFrame size alignedTo: self stackAlignment).
	].

	self
		addX86: JMP with: entryBlock
]

{ #category : #initialization }
SLVMLirX86CodeGenerator >> initialize [
	super initialize.
	compilationTarget := SLVMX86CompilationTarget new.
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> moveConstant: constant toMemoryInRegister: pointerRegister [
	self addX86: MOV with: pointerRegister asX86Ptr with: constant
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> moveConstant: value toRegister: register. [
	self halt.
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> moveLocal: localVariable toRegister: register. [
	register isVectorRegister ifTrue: [
		self halt. 
	] ifFalse: [
		self addX86: MOV with: register with: localVariable
	]
	
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> moveRegister: register toLocal: localVariable [
	self addX86: MOV with: localVariable with: register
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> moveRegister: value toMemory: pointer [
	self halt.
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> postProcessCodeGeneration [
	self generatePrologue
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> stackAlignment [
	^ 16
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitAlloca: instruction [
	| valueType size |
	valueType := instruction valueType.
	size := (valueType sizeForTarget: compilationTarget) alignedTo: self stackAlignment.
	self addX86: SUB with: ESP with: size.
	self instruction: instruction resultInRegister: ESP.
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitJump: instruction [
	| destination |
	destination := basicBlockDictionary at: instruction destination.
	self addX86: JMP with: destination
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitReturnVoid: instruction [
	self
		addX86: MOV with: ESP with: EBP;
		addX86: POP with: EBP;
		addX86: RET
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitStore: instruction [
	| valueType pointer value values |
	valueType := instruction value type.
	valueType isVectorType ifTrue: [ 
		valueType size = 16 ifTrue: [ 
			self halt.
		]
	] ifFalse: [ 
		valueType isFloatType ifTrue: [
			pointer := self ensureInstruction: instruction valueInRegister: instruction variable.
			value := self ensureInstruction: instruction valueInRegister: instruction value.
			"Store the float in memory"
			self halt.
		].
	
		valueType isIntegerType ifTrue: [
			values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
			value := values first.
			pointer := values second.
			"Move the integer"
			value isConstant ifTrue: [
				^ self moveConstant: value toMemoryInRegister: pointer
			] ifFalse: [
				^ self moveRegister: value toMemory: pointer
			]
		].
	].

	"Large object. Perform memcpy"
	self halt.
]
