Class {
	#name : #SLVMLirX86FunctionCodeGenerator,
	#superclass : #SLVMLirFunctionGenerator,
	#classVars : [
		'ComparisonBranchMap',
		'ComparisonNegatedBranchMap',
		'OperationCodeGeneratorMap'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'class initialization' }
SLVMLirX86FunctionCodeGenerator class >> initialize [
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
		
		fadd visitFloatAdd:
		fsub visitFloatSub:
		fmul visitFloatMul:
		fdiv visitFloatDiv:
	).
	
	ComparisonBranchMap := IdentityDictionary newFromPairs: {
		#ilt . JL .
		#ile . JLE .
		#ieq . JE .
		#ine . JNE .
		#igt . JG .
		#ige . JGE .

		#ult . JB .
		#ule . JBE .
		#ugt . JA .
		#uge . JAE .
	}.
	
	ComparisonNegatedBranchMap := IdentityDictionary newFromPairs: {
		#ilt . JGE .
		#ile . JG .
		#ieq . JNE .
		#ine . JE .
		#igt . JLE .
		#ige . JL .

		#ult . JAE .
		#ule . JA .
		#ugt . JBE .
		#uge . JB .
	}.
	
]

{ #category : #instructions }
SLVMLirX86FunctionCodeGenerator >> addX86: opcode [
	^ self addX86: opcode operands: #()
]

{ #category : #instructions }
SLVMLirX86FunctionCodeGenerator >> addX86: opcode operands: operands [
	operands do: [ :op |
		op isStackFrameVariable ifTrue: [ op actuallyUsed: true ]
	].

	currentBlockTarget addInstruction: (SLVMLirX86Instruction new opcode: opcode; operands: operands); yourself
]

{ #category : #instructions }
SLVMLirX86FunctionCodeGenerator >> addX86: opcode with: operand [
	^ self addX86: opcode operands: {operand asLirInstructionOperand}
]

{ #category : #instructions }
SLVMLirX86FunctionCodeGenerator >> addX86: opcode with: op1 with: op2 [
	^ self addX86: opcode operands: {op1 asLirInstructionOperand . op2 asLirInstructionOperand}
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> canBeFrameLess [
	^ true
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> ensureInstruction: instruction valueInRegister: value [
	^ registerAllocator moveInstruction: instruction value: value toRegisterWith: self
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> ensureInstructionValuesInRegistersOrImmediate: instruction [
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

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> generateActualReturn: instruction [
	lirFunction stackFrame frameLessMethod ifFalse: [
		self
			addX86: MOV with: ESP with: EBP;
			addX86: POP with: EBP.
	].

	self
		addX86: RET
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> generateActualReturns [
	function basicBlocks do: [ :bb |
		(bb lastInstruction isReturn or: [ bb lastInstruction isReturnVoid ]) ifTrue: [ 
			currentBlockTarget := basicBlockDictionary at: bb.
			self generateActualReturn: bb lastInstruction
		]
	]
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> generatePrologue [
	| prologueBlock stackFrame entryBlock |	
	self flag: 'Support multiples calling conventions'.
	
	"Allocate space for the variables"
	stackFrame := lirFunction stackFrame.
	stackFrame optimize.
	(stackFrame localVariables size = 0 and: [ self canBeFrameLess ]) ifTrue: [ 
		stackFrame
			argumentsBaseOffset: 4;
			frameLessMethod: true;
			buildLayout.
		^ true
	].

	stackFrame
		argumentsBaseOffset: 8;
		buildLayout.

	entryBlock := lirFunction basicBlocks first.
	prologueBlock := SLVMLirBasicBlock new.
	prologueBlock name: #prologue.
	lirFunction addFirstBasicBlock: prologueBlock.
	
	currentBlockTarget := prologueBlock.

	"Create the stack frame"
	self generateStackFrameBuildingJumpingInto: entryBlock
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> generateStackFrameBuildingJumpingInto: entryBlock [
	| stackFrame |
	self
		addX86: PUSH with: EBP;
		addX86: MOV with: EBP with: ESP.

	stackFrame := lirFunction stackFrame. 
	stackFrame size ~= 0 ifTrue: [
		self addX86: SUB with: ESP with: (stackFrame size alignedTo: self stackAlignment).
	].

	self
		addX86: JMP with: entryBlock
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> intResultRegister [
	^ EAX
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveConstant: constant toMemoryInRegister: pointerRegister [
	self addX86: MOV with: pointerRegister asX86Ptr with: constant
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveConstant: value toRegister: register. [
	self halt.
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveLocal: localVariable toRegister: register [
	register isVectorRegister ifTrue: [
		self halt. 
	] ifFalse: [
		self addX86: MOV with: register with: localVariable
	]
	
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveLocal: localVariable toRegisterLow: registerLow registerHigh: registerHigh [ 
	self
		addX86: MOV with: registerLow with: localVariable;
		addX86: MOV with: registerHigh with: localVariable + 4
	
	
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveRegister: register toLocal: localVariable [
	self addX86: MOV with: localVariable with: register
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveRegister: value toMemory: pointer [
	self halt.
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> postProcessCodeGeneration [
	self
		generatePrologue;
		generateActualReturns
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> secondIntResultRegister [
	^ ECX
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> stackAlignment [
	^ 16
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> translateBasicBlockInstructions: basicBlock [
	| current translated |
	current := basicBlock firstInstruction.
	[ current isNotNil ] whileTrue: [
		translated := false.
		(current type isScalarType and: [ current instructionReferences size = 1 and: [ current instructionReferences first = current nextInstruction ]]) ifTrue: [ 
			current isBinaryComparison ifTrue: [
				translated := true.
				self translateCompare: current andBranch: current nextInstruction.
				current := current nextInstruction nextInstruction
			].
		].
	
		translated ifFalse: [
			current accept: self.
			current := current nextInstruction
		]
	].

]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> translateCompare: comparison andBranch: branch [
	| values branchInstruction trueDestination falseDestination negatedBranchInstruction |
	values := self ensureInstructionValuesInRegistersOrImmediate: comparison.
	"branchInstruction := ComparisonBranchMap at: comparison operation."
	negatedBranchInstruction := ComparisonNegatedBranchMap at: comparison operation.
	trueDestination := basicBlockDictionary at: branch trueBlock.
	falseDestination := basicBlockDictionary at: branch falseBlock.
	
	comparison left type isIntegerType ifTrue: [ 
		self addX86: CMP with: values first with: values second.
	] ifFalse: [ 
		self halt.
	].

	self
		addX86: negatedBranchInstruction with: falseDestination;
		addX86: JMP with: trueDestination
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> translateComparison: instruction [
	| branchInstruction values result continueLabel |
	instruction type isScalarType ifTrue: [
		branchInstruction := ComparisonBranchMap at: instruction operation.
		
		values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
		result := self allocateInstructionResultRegister: instruction.
		continueLabel := self newLabel: #compareResult.
		self
			addX86: MOV with: result with: 1.
		
		instruction left type isIntegerType ifTrue: [ 
			self addX86: CMP with: values first with: values second.
		] ifFalse: [ 
			self halt.
		].
			
		self
			addX86: branchInstruction with: continueLabel;
			addX86: XOR with: result with: result;
			addLabel: continueLabel.
		self instruction: instruction resultInRegister: result.

	] ifFalse: [
		self halt.
	]
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitAdd: instruction [
	| values result |
	values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
	result := self allocateInstructionResultRegister: instruction.
	self
		addX86: MOV with: result with: values first;
		addX86: ADD with: result with: values second.
	self instruction: instruction resultInRegister: result.
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitAlloca: instruction [
	| valueType size |
	valueType := instruction valueType.
	size := (valueType sizeForTarget: compilationTarget) alignedTo: self stackAlignment.
	self addX86: SUB with: ESP with: size.
	self instruction: instruction resultInRegister: ESP.
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitBinaryOperation: instruction [
	| selector operationType |
	operationType := instruction operationType.
	(operationType == #integerComp or: [ operationType == #floatComp ]) ifTrue: [
		^ self translateComparison: instruction
	].

	selector := OperationCodeGeneratorMap at: instruction operation.
	^ self perform: selector with: instruction
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitBranch: instruction [
	| condition trueDestination falseDestination |
	condition := self ensureInstruction: instruction valueInRegister: instruction condition. 
	trueDestination := basicBlockDictionary at: instruction trueBlock.
	falseDestination := basicBlockDictionary at: instruction falseBlock.
	self
		addX86: TEST with: condition with: condition;
		addX86: JZ with: falseDestination;
		addX86: JMP with: trueDestination
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitJump: instruction [
	| destination |
	destination := basicBlockDictionary at: instruction destination.
	self addX86: JMP with: destination
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitReturn: instruction [
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
						self moveValue: returnValue toRegisterLow: self intResultRegister high: self secondIntResultRegister
					] ifFalse: [
						self moveValue: returnValue toRegister: self intResultRegister
					]
				].
			]
		]
	].

]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitReturnVoid: instruction [

]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitStore: instruction [
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
SLVMLirX86FunctionCodeGenerator >> visitSub: instruction [
	| values result |
	values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
	result := self allocateInstructionResultRegister: instruction.
	self
		addX86: MOV with: result with: values first;
		addX86: SUB with: result with: values second.
	self instruction: instruction resultInRegister: result.
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitUnreachable: instruction [

]
