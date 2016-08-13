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
			streamSize := streamSize + 16
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
SLVMX86MachineCodeGenerator >> generateADD: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.
	operandSize := first size.
	
	operandSize = 1 ifTrue: [
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r04; putInt8: second value ].
			writer put: 16r80.
			first encodeModRMWithOpcode: 0 into: writer.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r00.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		second isImmediate ifTrue: [
			first == AX ifTrue: [ ^ writer put: 16r05; putInt16: second value ].
			writer put: 16r81.
			first encodeModRMWithOpcode: 0 into: writer.
			^ writer putInt16: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r01.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 4 ifTrue: [
		second isImmediate ifTrue: [
			first == EAX ifTrue: [ ^ writer put: 16r05; putInt32: second value ].
			writer put: 16r81.
			first encodeModRMWithOpcode: 0 into: writer.
			^ writer putInt32: second value.
		].

		second isRegister ifTrue: [
			writer put: 16r01.
			^ first encodeModRMWithRegister: second into: writer.
		].
	].

	self halt.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateCMP: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.
	operandSize := first size.
	
	operandSize = 1 ifTrue: [
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r3C; putInt8: second value ].
			writer put: 16r80.
			first encodeModRMWithOpcode: 7 into: writer.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r38.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		second isImmediate ifTrue: [
			first == AX ifTrue: [ ^ writer put: 16r3D; putInt16: second value ].
			writer put: 16r81.
			first encodeModRMWithOpcode: 7 into: writer.
			^ writer putInt16: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r39.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 4 ifTrue: [
		second isImmediate ifTrue: [
			first == EAX ifTrue: [ ^ writer put: 16r3D; putInt32: second value ].
			writer put: 16r81.
			first encodeModRMWithOpcode: 7 into: writer.
			^ writer putInt32: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r39.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	self halt.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJCC: instruction opcode8: opcode8 opcode32: opcode32 [
	| operand delta |
	operand := instruction first.
	self assert: operand isLabel.
	
	delta := operand offset - writer position.
	(self isInShortRange: delta + 2) ifTrue: [
		^ writer put: opcode8; putInt8: delta - 2
	] ifFalse: [ 
		^ writer put: opcode32; putInt32: delta - 5
	]
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJG: instruction [
	^ self generateJCC: instruction opcode8: 16r7F opcode32: 16r8F
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJGE: instruction [
	^ self generateJCC: instruction opcode8: 16r7D opcode32: 16r8D
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJL: instruction [
	^ self generateJCC: instruction opcode8: 16r7C opcode32: 16r8C
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJLE: instruction [
	^ self generateJCC: instruction opcode8: 16r7E opcode32: 16r8E
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJMP: instruction [
	| operand delta |
	operand := instruction first.
	operand isLabel ifTrue: [
		delta := operand offset - writer position.
		(self isInShortRange: delta + 2) ifTrue: [
			^ writer put: 16rEB; putInt8: delta - 2
		] ifFalse: [ 
			^ writer put: 16rE9; putInt32: delta - 5
		]
	].

	self halt.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJNZ: instruction [
	^ self generateJCC: instruction opcode8: 16r75 opcode32: 16r85
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJZ: instruction [
	^ self generateJCC: instruction opcode8: 16r74 opcode32: 16r84
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
		].
	
		second isRegister ifTrue: [
			writer put: 16r28.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				first encodeModRMWithOpcode: 5 into: writer.
				^ writer putInt8: second value
			] ifFalse: [ 
				first == AX ifTrue: [ ^ writer put: 16r2D; putInt16: second value ].
				writer put: 16r81.
				first encodeModRMWithOpcode: 5 into: writer.
				^ writer putInt16: second value.
			]
		].
	
		second isRegister ifTrue: [
			writer put: 16r29.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 4 ifTrue: [
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				first encodeModRMWithOpcode: 5 into: writer.
				^ writer putInt8: second value
			] ifFalse: [ 
				first == EAX ifTrue: [ ^ writer put: 16r2D; putInt32: second value ].
				writer put: 16r81.
				first encodeModRMWithOpcode: 5 into: writer.
				^ writer putInt32: second value.
			]
		].

		second isRegister ifTrue: [
			writer put: 16r29.
			^ first encodeModRMWithRegister: second into: writer.
		].
	].

	self halt.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateTEST: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.
	operandSize := first size.
	
	operandSize = 1 ifTrue: [
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16rA8; putInt8: second value ].
			writer put: 16rF6.
			first encodeModRMWithOpcode: 0 into: writer.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r84.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		second isImmediate ifTrue: [
			first == AX ifTrue: [ ^ writer put: 16rA9; putInt16: second value ].
			writer put: 16rF7.
			first encodeModRMWithOpcode: 0 into: writer.
			^ writer putInt16: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r85.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 4 ifTrue: [
		second isImmediate ifTrue: [
			first == EAX ifTrue: [ ^ writer put: 16rA9; putInt32: second value ].
			writer put: 16rF7.
			first encodeModRMWithOpcode: 0 into: writer.
			^ writer putInt32: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r85.
			^ first encodeModRMWithRegister: second into: writer.
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

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateXOR: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.
	operandSize := first size.
	
	operandSize = 1 ifTrue: [
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r34; putInt8: second value ].
			writer put: 16r80.
			first encodeModRMWithOpcode: 6 into: writer.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r30.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		second isImmediate ifTrue: [
			first == AX ifTrue: [ ^ writer put: 16r35; putInt16: second value ].
			writer put: 16r81.
			first encodeModRMWithOpcode: 6 into: writer.
			^ writer putInt16: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r31.
			^ first encodeModRMWithRegister: second into: writer.
		]
	].

	operandSize = 4 ifTrue: [
		second isImmediate ifTrue: [
			first == EAX ifTrue: [ ^ writer put: 16r05; putInt32: second value ].
			writer put: 16r81.
			first encodeModRMWithOpcode: 6 into: writer.
			^ writer putInt32: second value.
		].

		second isRegister ifTrue: [
			writer put: 16r31.
			^ first encodeModRMWithRegister: second into: writer.
		].
	].

	self halt.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> isInShortRange: value [
	^ value value between: -128 and: 127
]
