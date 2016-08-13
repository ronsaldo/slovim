Class {
	#name : #SLVMX86MachineCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'instructionStream',
		'writer'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86MachineCodeGenerator >> computeInitialSizeEstimate [
	| streamSize |
	streamSize := 0.
	instructionStream instructionsDo: [ :instruction |
		instruction offset: streamSize.
		instruction isInstruction ifTrue: [
			instruction size: 16.
			streamSize := 16
		] ifFalse: [
			instruction size: 0
		]
	].
]

{ #category : #translating }
SLVMX86MachineCodeGenerator >> generate: aStream [
	instructionStream := aStream.
	self computeInitialSizeEstimate.
	^ self generateUntilConvergence
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateMOV: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.

	(first isRegister and: [ second isImmediate ]) ifTrue: [
		operandSize := first size.
		operandSize = 1 ifTrue: [
			writer put: 16rB0 + first value; put: second value
		].
		operandSize = 2 ifTrue: [
			writer put: 16r66; put: 16rB8 + first value; putInt16: second value
		].
		operandSize = 4 ifTrue: [
			writer put: 16rB8 + first value; putInt32: second value
		].
		^ self
	].
	
	(first isRegisterOrRegisterAddress and: [ second isImmediate ]) ifTrue: [
		operandSize := first size.
		operandSize = 1 ifTrue: [ writer put: 16rC6 ].
		operandSize = 2 ifTrue: [ writer put: 16r66; put: 16rC7 ].
		operandSize = 4 ifTrue: [ writer put: 16rC7 ].
		first encodeModRMWithOpcode: 0 into: writer.
		
		operandSize = 1 ifTrue: [ writer put: second value ].
		operandSize = 2 ifTrue: [ writer putInt16: second value ].
		operandSize = 4 ifTrue: [ writer putInt32: second value ].
		^ self
	].
 
	(first isRegisterOrRegisterAddress and: [ second isRegister ]) ifTrue: [
		writer put: 16r89.
		^ first encodeModRMWithRegister: second into: writer.
	].

	(first isRegister and: [ second isRegisterOrRegisterAddress ]) ifTrue: [
		writer put: 16r8B.
		^ second encodeModRMWithRegister: first into: writer.
	].

	self halt.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generatePOP: instruction [
	| operand |
	operand := instruction first.
	operand isImmediate ifTrue: [
		operand isSmallImmediate ifTrue: [ 
		] ifFalse: [ 
		]
	].

	operand isRegister ifTrue: [
		^ writer put: 16r58 + operand value.
	].

	operand isRegisterOrRegisterAddress ifTrue: [
		writer put: 16r8F.
		^ operand encodeModRMWithOpcode: 0 into: writer
	].

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generatePUSH: instruction [
	| operand |
	operand := instruction first.
	operand isImmediate ifTrue: [
		operand isSmallImmediate ifTrue: [ 
		] ifFalse: [ 
		]
	].

	operand isRegister ifTrue: [
		^ writer put: 16r50 + operand value.
	].

	operand isRegisterOrRegisterAddress ifTrue: [ 
		writer put: 16rFF.
		^ operand encodeModRMWithOpcode: 6 into: writer
	].

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateRET: instruction [
	instruction operands ifEmpty: [ 
		writer put: 16rC3
	] ifNotEmpty: [
		writer put: 16rC2; putInt16: instruction first
	]
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateSUB: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.
	operandSize := first size.
	
	operandSize = 1 ifTrue: [
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r2C; putInt8: second value ].
			writer put: 16r80.
			first encodeModRMWithOpcode: 5 into: writer.
			^ writer putInt8: second value.
		]
	].

	operandSize = 2 ifTrue: [
		second isImmediate ifTrue: [
			writer put: 16r66.
			first == AX ifTrue: [ ^ writer put: 16r2D; putInt16: second value ].
			writer put: 16r81.
			first encodeModRMWithOpcode: 5 into: writer.
			^ writer putInt16: second value.
		]
	].

	operandSize = 4 ifTrue: [
		second isImmediate ifTrue: [
			first == EAX ifTrue: [ ^ writer put: 16r2D; putInt32: second value ].
			writer put: 16r81.
			first encodeModRMWithOpcode: 5 into: writer.
			^ writer putInt32: second value.
		]
	].

	self halt.
]

{ #category : #translating }
SLVMX86MachineCodeGenerator >> generateUntilConvergence [
	| result oldResult selector |
	oldResult := nil.
	[
		result := SLVMLirMachineCodeWriter do: [ :out |
			writer := out.
			instructionStream instructionsDo: [ :ins |
				ins offset: out position.
				ins isInstruction ifTrue: [ 
					selector := InstructionOpcodeGeneratorMap at: ins opcode.
					self perform: selector with: ins. 
				].
			
				ins size: out position - ins offset.	
			]
		].
		oldResult = result ifTrue: [ ^ result ].
		oldResult := result
	] repeat
	

]
