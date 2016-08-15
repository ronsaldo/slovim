Class {
	#name : #SLVMLirX86FunctionCodeGenerator,
	#superclass : #SLVMLirFunctionCodeGenerator,
	#instVars : [
		'longMode'
	],
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
		shiftrightarithmetic visitShiftRightArithmetic:
		
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

{ #category : #'register allocation' }
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

{ #category : #'register allocation' }
SLVMLirX86FunctionCodeGenerator >> ensureInstructionValuesInRegistersOrMemory: instruction [
	| first second |
	self assert: instruction parameters size = 2.
	first := instruction parameters first.
	second := instruction parameters second.
	
	^ {self ensureInstruction: instruction valueInRegister: first . self ensureInstruction: instruction valueInRegister: second }
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> floatReturnRegister [
	^ nil
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

{ #category : #initialization }
SLVMLirX86FunctionCodeGenerator >> initialize [
	super initialize.
	longMode := false.
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> intResultRegister [
	^ EAX
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveConstant: constant toMemoryInRegister: pointerRegister [
	self addX86: MOV with: pointerRegister asX86Ptr with: constant
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveConstant: value toRegister: register [
	| memoryLocation valueType |
	valueType := value type.
	register isVectorRegister ifTrue: [
		memoryLocation := self putConstantInConstantZone: value.
		valueType isVectorType ifTrue: [
			valueType baseType size = 8 ifTrue: [
				self halt.
			] ifFalse: [
				self halt. 
			]
		] ifFalse: [ 
			valueType size = 8 ifTrue: [
				self addX86: MOVSD with: register with: memoryLocation asX86Ptr
			] ifFalse: [
				self addX86: MOVSS with: register with: memoryLocation asX86Ptr
			]
		]
	] ifFalse: [
		register size <= 8 ifTrue: [
			self addX86: MOV with: register with: value value
		] ifFalse: [ 
			self halt.
		]
	]
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveLocal: localVariable toRegisterLow: registerLow registerHigh: registerHigh [ 
	self
		addX86: MOV with: registerLow with: localVariable;
		addX86: MOV with: registerHigh with: localVariable + 4
	
	
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveLocal: localVariable type: localType toRegister: register [
	register isVectorRegister ifTrue: [
		localType isVectorType ifTrue: [
			localType baseType size = 8 ifTrue: [
				self halt.
			] ifFalse: [
				self halt. 
			]
		] ifFalse: [ 
			localType size = 8 ifTrue: [
				self addX86: MOVSD with: register with: localVariable
			] ifFalse: [
				self addX86: MOVSS with: register with: localVariable
			]
		]
	] ifFalse: [
		self addX86: MOV with: register with: localVariable
	]
	
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

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> scalarFloatBinaryInstruction: instruction x86Instruction: x86Instruction [
	| values result |
	values := self ensureInstructionValuesInRegistersOrMemory: instruction.
	result := self allocateInstructionResultRegister: instruction.
		
	self
		addX86: MOVAPD with: result with: values first;
		addX86: x86Instruction with: result with: values second.
	self instruction: instruction resultInRegister: result.

]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> scalarIntegerBinaryInstruction: instruction x86Instruction: x86Instruction carryDo: carryBlock [
	| values result |
	values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
	result := self allocateInstructionResultRegister: instruction.
		
	self
		addX86: MOV with: result with: values first;
		addX86: x86Instruction with: result with: values second.
	self instruction: instruction resultInRegister: result.

]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> scalarIntegerBinaryInstruction: instruction x86Instruction: x86Instruction carryInstruction: carryInstruction [
	| values result |
	values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
	result := self allocateInstructionResultRegister: instruction.
		
	self
		addX86: MOV with: result with: values first;
		addX86: x86Instruction with: result with: values second.
	self instruction: instruction resultInRegister: result.

]

{ #category : #'stack frame' }
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
	| baseType |
	(instruction type isVectorType or: [ instruction type isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 1 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PADDB ].
		baseType size = 2 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PADDW ].
		baseType size = 4 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PADDD ].
		baseType size = 8 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PADDQ ].		
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: ADD carryInstruction: ADC
	].


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
SLVMLirX86FunctionCodeGenerator >> visitBitAnd: instruction [
	(instruction type isVectorType or: [ instruction type isMatrixType ]) ifTrue: [
		self vectorBinaryInstruction: instruction x86Instruction: PAND		
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: AND carryInstruction: AND
	].
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitBitOr: instruction [
	(instruction type isVectorType or: [ instruction type isMatrixType ]) ifTrue: [
		self vectorBinaryInstruction: instruction x86Instruction: POR	
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: OR carryInstruction: OR
	].
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitBitXor: instruction [
	(instruction type isVectorType or: [ instruction type isMatrixType ]) ifTrue: [
		self vectorBinaryInstruction: instruction x86Instruction: PXOR	
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: XOR carryInstruction: XOR
	].
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
SLVMLirX86FunctionCodeGenerator >> visitFloatAdd: instruction [
	| instructionType baseType |
	instructionType := instruction type.
	(instructionType isVectorType or: [ instructionType isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 4 ifTrue: [ ^ self vectorBinaryInstruction: instruction x86Instruction: ADDPS ].
		baseType size = 8 ifTrue: [ ^ self vectorBinaryInstruction: instruction x86Instruction: ADDPD ].		
	] ifFalse: [
		instructionType size = 4 ifTrue: [ self scalarFloatBinaryInstruction: instruction x86Instruction: ADDSS ].
		instructionType size = 8 ifTrue: [ self scalarFloatBinaryInstruction: instruction x86Instruction: ADDSD ].
	].


]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitFloatDiv: instruction [
	| instructionType baseType |
	instructionType := instruction type.
	(instructionType isVectorType or: [ instructionType isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 4 ifTrue: [ ^ self vectorBinaryInstruction: instruction x86Instruction: DIVPS ].
		baseType size = 8 ifTrue: [ ^ self vectorBinaryInstruction: instruction x86Instruction: DIVPD ].		
	] ifFalse: [
		instructionType size = 4 ifTrue: [ self scalarFloatBinaryInstruction: instruction x86Instruction: DIVSS ].
		instructionType size = 8 ifTrue: [ self scalarFloatBinaryInstruction: instruction x86Instruction: DIVSD ].
	].


]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitFloatMul: instruction [
	| instructionType baseType |
	instructionType := instruction type.
	(instructionType isVectorType or: [ instructionType isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 4 ifTrue: [ ^ self vectorBinaryInstruction: instruction x86Instruction: MULPS ].
		baseType size = 8 ifTrue: [ ^ self vectorBinaryInstruction: instruction x86Instruction: MULPD ].		
	] ifFalse: [
		instructionType size = 4 ifTrue: [ self scalarFloatBinaryInstruction: instruction x86Instruction: MULSS ].
		instructionType size = 8 ifTrue: [ self scalarFloatBinaryInstruction: instruction x86Instruction: MULSD ].
	].


]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitFloatSub: instruction [
	| instructionType baseType |
	instructionType := instruction type.
	(instructionType isVectorType or: [ instructionType isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 4 ifTrue: [ ^ self vectorBinaryInstruction: instruction x86Instruction: SUBPS ].
		baseType size = 8 ifTrue: [ ^ self vectorBinaryInstruction: instruction x86Instruction: SUBPD ].		
	] ifFalse: [
		instructionType size = 4 ifTrue: [ self scalarFloatBinaryInstruction: instruction x86Instruction: SUBSS ].
		instructionType size = 8 ifTrue: [ self scalarFloatBinaryInstruction: instruction x86Instruction: SUBSD ].
	].


]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitJump: instruction [
	| destination |
	destination := basicBlockDictionary at: instruction destination.
	self addX86: JMP with: destination
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitReturn: instruction [
	| returnValue returnValueType returnSize floatReg memoryLocation |
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
				floatReg := self floatReturnRegister.
				floatReg ifNil: [ 
					memoryLocation := self ensureInstruction: instruction valueInMemory: returnValue.
					self addX86: FLD with: (memoryLocation asX86PtrOfSize: returnSize)
				] ifNotNil: [
					self moveValue: returnValue toRegister: floatReg
				] 
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
SLVMLirX86FunctionCodeGenerator >> visitShiftLeft: instruction [
	| baseType |
	(instruction type isVectorType or: [ instruction type isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 1 ifTrue: [ self halt. ].
		baseType size = 2 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PSLLW ].
		baseType size = 4 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PSLLD ].
		baseType size = 8 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PSLLQ ].		
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: SHR carryDo: [
			self halt
		]
	].


]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitShiftRight: instruction [
	| baseType |
	(instruction type isVectorType or: [ instruction type isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 1 ifTrue: [ self halt. ].
		baseType size = 2 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PSLLW ].
		baseType size = 4 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PSLLD ].
		baseType size = 8 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PSLLQ ].		
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: SHL carryDo: [
			self halt
		]
	].


]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitShiftRightArithmetic: instruction [
	| baseType |
	(instruction type isVectorType or: [ instruction type isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 1 ifTrue: [ self halt. ].
		baseType size = 2 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PSRAW ].
		baseType size = 4 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PSRAD ].
		baseType size = 8 ifTrue: [ self halt ].		
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: SAR carryDo: [
			self halt
		]
	].


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
	| baseType |
	(instruction type isVectorType or: [ instruction type isMatrixType ]) ifTrue: [
		baseType := instruction type baseType.
		baseType size = 1 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PADDB ].
		baseType size = 2 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PADDW ].
		baseType size = 4 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PADDD ].
		baseType size = 8 ifTrue: [ self vectorBinaryInstruction: instruction x86Instruction: PADDQ ].		
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: SUB carryInstruction: SBB
	].
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitUnreachable: instruction [

]
