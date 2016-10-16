Class {
	#name : #'SLVMLirX86_64FunctionCodeGenerator',
	#superclass : #SLVMLirX86FunctionCodeGenerator,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #accessing }
SLVMLirX86_64FunctionCodeGenerator >> framePointerRegister [
	^ RBP
]

{ #category : #'stack frame' }
SLVMLirX86_64FunctionCodeGenerator >> generateActualReturn: instruction [
	lirFunction stackFrame frameLessMethod ifFalse: [
		self
			addX86: MOV with: RSP with: EBP;
			addX86: POP with: RBP.
	].

	callingConvention isStackCleanedByCaller ifTrue: [ 
		self addX86: RET
	] ifFalse: [
		self addX86: RET with: (lirFunction stackFrame argumentsSize alignedTo: callingConvention stackAlignment)
	]
]

{ #category : #'stack frame' }
SLVMLirX86_64FunctionCodeGenerator >> generateStackFrameBuildingJumpingInto: entryBlock [
	| stackFrame |
	self
		addX86: PUSH with: RBP;
		addX86: MOV with: RBP with: RSP.

	stackFrame := lirFunction stackFrame. 
	stackFrame size ~= 0 ifTrue: [
		self addX86: SUB with: RSP with: (stackFrame size alignedTo: self stackAlignment).
	].

	registerAllocator emitPrologueWith: self.
	
	self
		addX86: JMP with: entryBlock
]

{ #category : #initialization }
SLVMLirX86_64FunctionCodeGenerator >> initialize [
	super initialize.
	longMode := true.
]

{ #category : #accessing }
SLVMLirX86_64FunctionCodeGenerator >> stackArgumentAlignment [
	^ 8
]

{ #category : #accessing }
SLVMLirX86_64FunctionCodeGenerator >> stackPointerRegister [
	^ RSP
]
