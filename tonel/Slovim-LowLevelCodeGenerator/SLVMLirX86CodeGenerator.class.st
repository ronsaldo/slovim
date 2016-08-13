Class {
	#name : #SLVMLirX86CodeGenerator,
	#superclass : #SLVMLirGenerator,
	#classVars : [
		'OperationCodeGeneratorMap'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86CodeGenerator class >> initialize [
	super initialize.
	
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

		ilt visitSignedLessThan:
		ile visitSignedLessEqual:
		ieq visitSignedEqual:
		ine visitSignedNotEqual:
		igt visitSignedGreaterThan:
		ige visitSignedGreaterEqual:
		
		fadd visitFloatAdd:
		fsub visitFloatSub:
		fmul visitFloatMul:
		fdiv visitFloatDiv:
	).
	
]

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

{ #category : #visitor }
SLVMLirX86CodeGenerator >> generateIntegerCompare: compare instruction: instruction [
	| values result continueLabel |
	values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
	result := self allocateInstructionResultRegister: instruction.
	continueLabel := self newLabel: #compareResult.
	self
		addX86: CMP with: values first with: values second;
		addX86: MOV with: result with: 1;
		addX86: compare with: continueLabel;
		addX86: XOR with: result with: result;
		addX86: JMP with: continueLabel;
		addLabel: continueLabel.
	self instruction: instruction resultInRegister: result.

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
	self flag: 'Support multiples calling conventions'.
	stackFrame argumentsBaseOffset: 8.
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

{ #category : #visitor }
SLVMLirX86CodeGenerator >> leaveFrame [
	self
		addX86: MOV with: ESP with: EBP;
		addX86: POP with: EBP;
		addX86: RET
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
SLVMLirX86CodeGenerator >> moveLocal: localVariable toRegister: register [
	register isVectorRegister ifTrue: [
		self halt. 
	] ifFalse: [
		self addX86: MOV with: register with: localVariable
	]
	
]

{ #category : #'code generation' }
SLVMLirX86CodeGenerator >> moveLocal: localVariable toRegisterLow: registerLow registerHigh: registerHigh [ 
	self
		addX86: MOV with: registerLow with: localVariable;
		addX86: MOV with: registerHigh with: localVariable + 4
	
	
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
SLVMLirX86CodeGenerator >> visitAdd: instruction [
	| values result |
	values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
	result := self allocateInstructionResultRegister: instruction.
	self
		addX86: MOV with: result with: values first;
		addX86: ADD with: result with: values second.
	self instruction: instruction resultInRegister: result.
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
SLVMLirX86CodeGenerator >> visitBinaryOperation: instruction [
	| selector |
	selector := OperationCodeGeneratorMap at: instruction operation.
	^ self perform: selector with: instruction
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitBranch: instruction [
	| condition trueDestination falseDestination |
	condition := self ensureInstruction: instruction valueInRegister: instruction condition. 
	trueDestination := basicBlockDictionary at: instruction trueBlock.
	falseDestination := basicBlockDictionary at: instruction falseBlock.
	self
		addX86: TEST with: condition with: condition;
		addX86: JNZ with: trueDestination;
		addX86: JMP with: falseDestination
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitJump: instruction [
	| destination |
	destination := basicBlockDictionary at: instruction destination.
	self addX86: JMP with: destination
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitReturn: instruction [
	| returnValue returnValueType returnSize |
	returnValue := instruction value.
	returnValueType := returnValue type.
	returnValueType isMatrixType ifTrue: [ 
		self halt.
	].

	returnValueType isVectorType ifTrue: [ 
	] ifFalse: [
		returnSize := returnValueType sizeForTarget: compilationTarget.
		returnSize <= 8 ifTrue: [ 
			returnValueType isFloatType ifTrue: [
				self halt. 
			] ifFalse: [ 
				returnValueType isIntegerType ifTrue: [
					returnSize = 8 ifTrue: [
						self moveValue: returnValue toRegisterLow: TempRegister high: TempRegister2
					] ifFalse: [
						self moveValue: returnValue toRegister: TempRegister
					]
				].
			]
		]
	].

	self leaveFrame
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitReturnVoid: instruction [
	self leaveFrame
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitSignedLessThan: instruction [
	self generateIntegerCompare: JL instruction: instruction
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

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitSub: instruction [
	| values result |
	values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
	result := self allocateInstructionResultRegister: instruction.
	self
		addX86: MOV with: result with: values first;
		addX86: SUB with: result with: values second.
	self instruction: instruction resultInRegister: result.
]

{ #category : #visitor }
SLVMLirX86CodeGenerator >> visitUnreachable: instruction [

]
