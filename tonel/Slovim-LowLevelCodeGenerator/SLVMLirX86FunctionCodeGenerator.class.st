Class {
	#name : #SLVMLirX86FunctionCodeGenerator,
	#superclass : #SLVMLirFunctionCodeGenerator,
	#instVars : [
		'longMode',
		'usesStackPointer'
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

	currentBlockTarget addInstruction: (SLVMLirX86Instruction new
		opcode: opcode;
		operands: operands;
		yourself)
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
	^ callingConvention canBeFrameLess
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> emitCallResultToRegister: instruction convention: calledConvention [
	| resultType tempAddress resultRegister |
	resultType := instruction type.
	resultType isVectorType ifTrue: [
		resultType size <= 16 ifTrue: [ 
			self instruction: instruction resultInRegister: XMM0.
		].
		resultType size <= 32 ifTrue: [ 
			self instruction: instruction resultInRegister: XMM0 secondRegister: XMM1.
		].
		resultType size > 32 ifTrue: [
			self error: 'unsupported argument type.'
		].
		
	] ifFalse: [
		resultType isFloatType ifTrue: [
			calledConvention floatReturnRegister ifNotNil: [
				resultRegister := calledConvention floatReturnRegister
			] ifNil: [
				resultRegister := self allocateInstructionResultRegister: instruction.
				tempAddress := (self stackPointerRegister asX86PtrOfSize: resultType size) - resultType size.
				self addX86: FST with: tempAddress. 
				self assert: (#(4 8) includes: resultType size).
				resultType size = 4 ifTrue: [
					self addX86: MOVSS with: resultRegister with: tempAddress. 
				].
				resultType size = 8 ifTrue: [
					self addX86: MOVSD with: resultRegister with: tempAddress. 
				].
			].
		
			self instruction: instruction resultInRegister: resultRegister.
		] ifFalse: [ 
			(resultType size <= 4 or: [ longMode and: [ resultType size <= 8] ])  ifTrue: [ 
				self instruction: instruction resultInRegister: calledConvention intResultRegister
			] ifFalse: [ 
				self instruction: instruction resultInRegister: calledConvention intResultRegister secondRegister: calledConvention secondIntResultRegister.
			].
		]
	]
	
]

{ #category : #'register allocation' }
SLVMLirX86FunctionCodeGenerator >> ensureInstruction: instruction valueInRegisterOrImmediate: value scratchIndex: scratchIndex [
	value isConstant ifTrue: [ ^ self translateConstant: value ].
	^ self ensureInstruction: instruction valueInRegister: value scratchIndex: scratchIndex
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

	first isConstant ifTrue: [ ^ { first . self ensureInstruction: instruction valueInRegister: second scratchIndex: 1 } ].
	second isConstant ifTrue: [ ^ { self ensureInstruction: instruction valueInRegister: first scratchIndex: 1 . second } ].
	^ { self ensureInstruction: instruction valueInRegister: first scratchIndex: 1 . self ensureInstruction: instruction valueInRegister: second  scratchIndex: 2}
]

{ #category : #'register allocation' }
SLVMLirX86FunctionCodeGenerator >> ensureInstructionValuesInRegistersOrMemory: instruction [
	| first second |
	self assert: instruction parameters size = 2.
	first := instruction parameters first.
	second := instruction parameters second.
	
	^ {self ensureInstruction: instruction valueInRegister: first scratchIndex: 1. self ensureInstruction: instruction valueInRegister: second scratchIndex: 2 }
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> floatReturnRegister [
	^ callingConvention floatReturnRegister
]

{ #category : #accessing }
SLVMLirX86FunctionCodeGenerator >> framePointerRegister [
	^ EBP
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> generateActualReturn: instruction [
	lirFunction stackFrame frameLessMethod ifFalse: [
		self
			addX86: MOV with: ESP with: EBP;
			addX86: POP with: EBP.
	].

	callingConvention isStackCleanedByCaller ifTrue: [ 
		self addX86: RET
	] ifFalse: [
		self addX86: RET with: lirFunction stackFrame argumentsSize
	]

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
	| prologueBlock stackFrame entryBlock framelessPrologue |	
	self flag: 'Support multiples calling conventions'.
	
	"Allocate space for the variables"
	stackFrame := lirFunction stackFrame.
	stackFrame optimize.
	(stackFrame localVariables size = 0 and: [ self canBeFrameLess and: [usesStackPointer not ]]) ifTrue: [ 
		framelessPrologue := true.
		stackFrame
			argumentsBaseOffset: 4;
			frameLessMethod: true;
			buildLayout.
	] ifFalse: [ 
		framelessPrologue := false.
		stackFrame
			argumentsBaseOffset: 8;
			buildLayout.
	].

	entryBlock := lirFunction basicBlocks first.
	prologueBlock := SLVMLirBasicBlock new.
	prologueBlock name: #prologue.
	lirFunction addFirstBasicBlock: prologueBlock.
	
	currentBlockTarget := prologueBlock.

	"Create the stack frame"
	framelessPrologue ifTrue: [
		self generateStackFramelessBuildingJumpingInto: entryBlock		
	] ifFalse: [
		self generateStackFrameBuildingJumpingInto: entryBlock
	]
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

	registerAllocator emitPrologueWith: self.

	self
		addX86: JMP with: entryBlock
]

{ #category : #'as yet unclassified' }
SLVMLirX86FunctionCodeGenerator >> generateStackFramelessBuildingJumpingInto: entryBlock [
	registerAllocator emitPrologueWith: self.

	self
		addX86: JMP with: entryBlock
]

{ #category : #initialization }
SLVMLirX86FunctionCodeGenerator >> initialize [
	super initialize.
	longMode := false.
	usesStackPointer := false.
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> instruction: instruction pushValue: value variadicArgument: isVariadicArgument [
	| valueType register stackAddress stackArgumentSize |
	value isConstant ifTrue: [ ^ self pushConstantValue: value variadicArgument: isVariadicArgument].
	valueType := value type.
	valueType isScalarIntegerType ifTrue: [
		((longMode not and: [ valueType size <= 4 ]) or:
		 [longMode and: [ valueType size <= 8 ]]) ifTrue: [
			register := self ensureInstruction: instruction valueInRegisterOrLocalForPushing: value.
			^ self addX86: PUSH with: register.
		] ifFalse: [
			self halt.
		]
	].

	valueType isFloatType ifTrue: [
		register := self ensureInstruction: instruction valueInRegisterForPushing: value.
		stackArgumentSize := valueType size alignedTo: self stackArgumentAlignment.
		stackAddress := (self stackPointerRegister asX86PtrOfSize: valueType size) - stackArgumentSize.
		valueType size = 4 ifTrue: [
			isVariadicArgument ifTrue: [
				"Variadic floats are passed as doubles"
				stackArgumentSize := 8.
				stackAddress := (self stackPointerRegister asX86PtrOfSize: valueType size) - stackArgumentSize.
				self addX86: CVTSS2SD with: register with: register.
				self addX86: MOVSD with: stackAddress with: register.
			] ifFalse: [ 
				self addX86: MOVSS with: stackAddress with: register.
			]
		].
		valueType size = 8 ifTrue: [
			self addX86: MOVSD with: stackAddress with: register.
		].

		^ self addX86: SUB with: self stackPointerRegister with: stackArgumentSize.
	].

	valueType isVectorType ifTrue: [
		self halt.
	].

	self halt.
]

{ #category : #'stack frame' }
SLVMLirX86FunctionCodeGenerator >> intResultRegister [
	^ callingConvention intResultRegister
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveConstant: constant toMemoryInRegister: pointerRegister [
	self addX86: MOV with: pointerRegister asX86Ptr with: constant
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveConstant: value toRegister: register [
	| memoryLocation valueType constantValue |
	valueType := value type.
	constantValue := self translateConstant: value.
	valueType isDynamicObjectType ifTrue: [
		value isConstantValue ifTrue: [ 
			^ self addX86: MOV with: register with: (self encodeImmediateObject: value value)
		].
	
		value isConstantDynamicLiteral ifTrue: [
			^ self addX86: MOV with: register with: (self addressOfLiteral: value) asX86Ptr
		]
	].

	self assert: value isConstantValue.
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
		valueType size <= 8 ifTrue: [
			self addX86: MOV with: register with: constantValue
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
		localVariable size < register size ifTrue: [
			self halt.
		] ifFalse: [ 
			self addX86: MOV with: register with: localVariable
		]
	]
	
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveRegister: register toLocal: localVariable [
	register isVectorRegister ifTrue: [
		localVariable size = 4 ifTrue: [ 
			self addX86: MOVSS with: localVariable with: register
		] ifFalse: [ 
			self addX86: MOVSD with: localVariable with: register
		]
	] ifFalse: [
		localVariable size < register size ifTrue: [ 
			self halt
		] ifFalse: [
			self addX86: MOV with: localVariable with: register
		]
	]

]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveRegister: value toMemory: pointer [
	self halt.
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> moveRegister: oldRegister toRegister: newRegister [
	oldRegister == newRegister ifTrue: [ ^ self ].
	self assert: oldRegister isVectorRegister = newRegister isVectorRegister.
	oldRegister isVectorRegister ifTrue: [
		self addX86: MOVAPD with: newRegister with: oldRegister.
	] ifFalse: [
		self addX86: MOV with: newRegister with: oldRegister.
	]
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> postProcessCodeGeneration [
	self
		generatePrologue;
		generateActualReturns
]

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> pushConstantValue: value variadicArgument: isVariadicArgument [
	| valueType memoryLocation integerData bitMask |
	valueType := value type.
	valueType isDynamicObjectType ifTrue: [
		value isCompiledMethodMetaData ifTrue: [
			^ self addX86: PUSH with: (self translateConstant: value sourceMethod) compiledMethodMetaData
		].
	
		value isConstantValue ifTrue: [ 
			^ self addX86: PUSH with: (self encodeImmediateObject: value value)
		].
	
		value isConstantDynamicLiteral ifTrue: [
			^ self addX86: PUSH with: (self addressOfLiteral: value) asX86Ptr
		]
	].

	value isConstantPointer ifTrue: [
		value constant ifNil: [
			^ self addX86: PUSH with: 0.
		] ifNotNil: [ 
			memoryLocation := self putConstantInConstantZone: value constant.
			^ self addX86: PUSH with: memoryLocation.
		]
	].

	(value isConstantValue and: [ valueType isScalarIntegerType or: [ valueType isFloatType ] ]) ifTrue: [ 
		valueType isFloatType ifTrue: [ 
			(valueType size <= 4 and: [ isVariadicArgument not ]) ifTrue: [
				integerData := value value asIEEE32BitWord
 			].
			(valueType size = 8 or: [valueType size <= 8 and: [ isVariadicArgument ]]) ifTrue: [
				integerData := ((value value basicAt: 1) << 32) | (value value basicAt: 2).
			].
		] ifFalse: [
			integerData := value value asInteger.
		].
	
		bitMask := integerData bitAnd: 16rFFFFFFFF.
		longMode ifTrue: [
			(integerData between: -2147483648 and: 2147483647) ifTrue: [ 
				memoryLocation := self putConstantInConstantZone: value. 
				^ self addX86: PUSH with: memoryLocation asX86Ptr
			]
		].

		self addX86: PUSH with: (integerData bitAnd: 16rFFFFFFFF).
		integerData := integerData >> 32.
		integerData ~= 0 ifTrue: [ self addX86: PUSH with: (integerData bitAnd: 16rFFFFFFFF) ].
		^ self
	].

	"Big constant"
	memoryLocation := self putConstantInConstantZone: value.
	valueType size <= self stackArgumentAlignment ifTrue: [ 
		self addX86: PUSH with: memoryLocation asX86Ptr
	] ifFalse: [
		self halt
	] 
	
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
	^ callingConvention secondIntResultRegister
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> stackAlignment [
	^ 16
]

{ #category : #accessing }
SLVMLirX86FunctionCodeGenerator >> stackArgumentAlignment [
	^ 4
]

{ #category : #accessing }
SLVMLirX86FunctionCodeGenerator >> stackPointerRegister [
	^ ESP
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
				registerAllocator instruction: current translationDo: [
					self translateCompare: current andBranch: current nextInstruction.
				].
				current := current nextInstruction nextInstruction
			].
		].
	
		translated ifFalse: [
			registerAllocator instruction: current translationDo: [
				current accept: self.
			].
			current := current nextInstruction
		]
	].


]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> translateCompare: comparison andBranch: branch [
	| values trueDestination falseDestination negatedBranchInstruction valueType |
	values := self ensureInstructionValuesInRegistersOrImmediate: comparison.
	"branchInstruction := ComparisonBranchMap at: comparison operation."
	negatedBranchInstruction := ComparisonNegatedBranchMap at: comparison operation.
	trueDestination := basicBlockDictionary at: branch trueBlock.
	falseDestination := basicBlockDictionary at: branch falseBlock.
	
	valueType := comparison left type.
	valueType isScalarIntegerType ifTrue: [ 
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
	| branchInstruction values result continueLabel valueType |
	instruction type isScalarType ifTrue: [
		branchInstruction := ComparisonBranchMap at: instruction operation.
		
		values := self ensureInstructionValuesInRegistersOrImmediate: instruction.
		result := self allocateInstructionResultRegister: instruction.
		continueLabel := self newLabel: #compareResult.
		self
			addX86: MOV with: result with: 1.
		
		valueType := instruction left type.
		valueType isScalarIntegerType ifTrue: [ 
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

{ #category : #'code generation' }
SLVMLirX86FunctionCodeGenerator >> translateConstant: constant [
	constant isGlobalValue ifTrue: [ ^ constant accept: moduleTranslator ].
	^ constant
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitAdd: instruction [
	| baseType |
	(instruction type isVectorType) ifTrue: [
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
	size := valueType size alignedTo: self stackAlignment.
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
	(instruction type isVectorType) ifTrue: [
		self vectorBinaryInstruction: instruction x86Instruction: PAND		
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: AND carryInstruction: AND
	].
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitBitOr: instruction [
	(instruction type isVectorType) ifTrue: [
		self vectorBinaryInstruction: instruction x86Instruction: POR	
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: OR carryInstruction: OR
	].
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitBitXor: instruction [
	(instruction type isVectorType) ifTrue: [
		self vectorBinaryInstruction: instruction x86Instruction: PXOR	
	] ifFalse: [
		self scalarIntegerBinaryInstruction: instruction x86Instruction: XOR carryInstruction: XOR
	].
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitBranch: instruction [
	| condition trueDestination falseDestination |
	condition := self ensureInstruction: instruction valueInRegister: instruction condition scratchIndex: 1. 
	trueDestination := basicBlockDictionary at: instruction trueBlock.
	falseDestination := basicBlockDictionary at: instruction falseBlock.
	self
		addX86: TEST with: condition with: condition;
		addX86: JZ with: falseDestination;
		addX86: JMP with: trueDestination
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitCall: instruction [
	| cleanUpSize calledFunction emittedCount variadicArgumentCount calledFunctionType calledConvention |
	cleanUpSize := 0.
	usesStackPointer := true.
	calledFunctionType := instruction functionType.
	variadicArgumentCount := instruction arguments size - calledFunctionType arguments size.
	
	"Spill the registers that are owned by the called."
	calledConvention := compilationTarget callingConventionDescriptionNamed: calledFunctionType callingConvention.
	registerAllocator spillCalledRegisterForConvention: calledConvention at: instruction with: self.

	"Push the arguments in the stack."	
	emittedCount := 0.
	instruction arguments reverseDo: [ :arg |
		self instruction: instruction pushValue: arg variadicArgument: emittedCount < variadicArgumentCount.
		emittedCount := emittedCount + 1.
		cleanUpSize := cleanUpSize + (arg type size alignedTo: self stackArgumentAlignment).
	].

	"ToDo: Move the arguments that are placed in registers."

	calledFunction := self ensureInstruction: instruction valueInRegisterOrImmediate: instruction functionValue scratchIndex: 1.
	self addX86: CALL with: calledFunction.
	(calledConvention isStackCleanedByCaller and: [ cleanUpSize > 0 ]) ifTrue: [
		self addX86: ADD with: self stackPointerRegister with: cleanUpSize
	].

	"Unspill the called registers."
	registerAllocator unspillCalledRegisterForConvention: calledConvention at: instruction with: self.

	instruction instructionReferences ifEmpty: [ ^ self ].
	self emitCallResultToRegister: instruction convention: calledConvention.
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitFloatAdd: instruction [
	| instructionType baseType |
	instructionType := instruction type.
	(instructionType isVectorType) ifTrue: [
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
	(instructionType isVectorType) ifTrue: [
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
	(instructionType isVectorType) ifTrue: [
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
	(instructionType isVectorType) ifTrue: [
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
SLVMLirX86FunctionCodeGenerator >> visitMessageSend: instruction [
	| cleanUpSize calledFunction oopArguments nativeArguments selector receiver nativeArgumentsSize argumentSizeDescription calledConvention |
	cleanUpSize := 0.
	usesStackPointer := true.
	
	oopArguments := OrderedCollection new.
	nativeArguments := OrderedCollection new.

	"Spill the registers that are owned by the called."
	calledConvention := compilationTarget callingConventionDescriptionNamed: #smalltalk.
	registerAllocator spillCalledRegisterForConvention: calledConvention at: instruction with: self.
	
	instruction arguments reverseDo: [ :arg |
		arg type isDynamicObjectType ifTrue: [
			oopArguments add: arg
		] ifFalse: [
			nativeArguments add: arg
		]
	].

	nativeArguments do: [ :arg |
		self instruction: instruction pushValue: arg variadicArgument: false.
		cleanUpSize := cleanUpSize + (arg type size alignedTo: self stackArgumentAlignment).
	].
	nativeArgumentsSize := cleanUpSize.

	oopArguments do: [ :arg |
		self instruction: instruction pushValue: arg variadicArgument: false.
		cleanUpSize := cleanUpSize + (arg type size alignedTo: self stackArgumentAlignment).
	].

	"Push the receiver"
	receiver := instruction receiver.
	self instruction: instruction pushValue: receiver variadicArgument: false.
	cleanUpSize := cleanUpSize + receiver type size.
	
	"Push the selector."
	selector := instruction selector.
	self instruction: instruction pushValue: selector variadicArgument: false.
	cleanUpSize := cleanUpSize + selector type size.
	
	"ToDo: Move the arguments that are placed in registers."

	"Push the Ns"
	argumentSizeDescription := (nativeArgumentsSize << 16 | oopArguments size).
	self addX86: PUSH with: argumentSizeDescription.

	calledFunction := moduleTranslator runtimeProvidedFunction: #'_slvm_dynrun_send_trap'.
	self addX86: CALL with: calledFunction.
	(calledConvention isStackCleanedByCaller and: [ cleanUpSize > 0 ]) ifTrue: [
		self addX86: ADD with: self stackPointerRegister with: cleanUpSize
	].

	"Unspill the called regsiters"
	registerAllocator unspillCalledRegisterForConvention: calledConvention at: instruction with: self.

	instruction instructionReferences ifEmpty: [ ^ self ].
	self emitCallResultToRegister: instruction convention: calledConvention.
	
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitReturn: instruction [
	| returnValue returnValueType returnSize floatReg memoryLocation |
	returnValue := instruction value.
	returnValueType := returnValue type.
	returnValueType isVectorType ifTrue: [
		self halt.
	] ifFalse: [
		returnSize := returnValueType size.
		returnSize <= 8 ifTrue: [ 
			returnValueType isFloatType ifTrue: [
				floatReg := self floatReturnRegister.
				floatReg ifNil: [ 
					memoryLocation := self ensureInstruction: instruction valueInMemory: returnValue.
					^ self addX86: FLD with: (memoryLocation asX86PtrOfSize: returnSize)
				] ifNotNil: [
					^ self moveValue: returnValue toRegister: floatReg
				] 
			] ifFalse: [ 
				returnValueType isScalarIntegerType ifTrue: [
					(returnSize = 8 and: [ longMode not ]) ifTrue: [
						^ self moveValue: returnValue toRegisterLow: self intResultRegister high: self secondIntResultRegister
					] ifFalse: [
						^ self moveValue: returnValue toRegister: self intResultRegister
					]
				].
			]
		]
	].

	self error: 'unsupported return type.'.
]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitReturnVoid: instruction [

]

{ #category : #visitor }
SLVMLirX86FunctionCodeGenerator >> visitShiftLeft: instruction [
	| baseType |
	(instruction type isVectorType) ifTrue: [
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
	(instruction type isVectorType) ifTrue: [
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
	(instruction type isVectorType) ifTrue: [
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
			pointer := self ensureInstruction: instruction valueInRegister: instruction variable scratchIndex: 1.
			value := self ensureInstruction: instruction valueInRegister: instruction value scratchIndex: 1.
			self assert: pointer ~= value.
			"Store the float in memory"
			self halt.
		].
	
		valueType isScalarIntegerType ifTrue: [
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
	(instruction type isVectorType) ifTrue: [
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
