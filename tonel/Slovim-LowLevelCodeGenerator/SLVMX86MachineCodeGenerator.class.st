Class {
	#name : #SLVMX86MachineCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'instructionStream',
		'writer',
		'longMode'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #translating }
SLVMX86MachineCodeGenerator >> computeInitialSizeEstimate [
	| streamSize |
	streamSize := 0.
	instructionStream sections do: [:section |
		section instructionsDo: [ :instruction |
			instruction offset: streamSize.
			instruction isInstruction ifTrue: [
				instruction size: 16.
				streamSize := streamSize + 16
			] ifFalse: [
				instruction isBlob ifTrue: [ 
					streamSize := streamSize + instruction size
				] ifFalse: [
					instruction size: (instruction size ifNil: [ 0 ])
				]
			]
		].
	]
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> encodeModRM: registerOrAddress opcode: opcode [
	registerOrAddress encodeModRMWithOpcode: opcode immediate: 0 longMode: longMode into: writer
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> encodeModRM: registerOrAddress opcode: opcode immediate: immediateSize [
	registerOrAddress encodeModRMWithOpcode: opcode immediate: immediateSize longMode: longMode into: writer
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> encodeModRM: registerOrAddress reg: reg [
	registerOrAddress encodeModRMWithOpcode: reg valueLow immediate: 0 longMode: longMode into: writer
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> encodeModRM: registerOrAddress reg: reg immediate: immediateSize [
	registerOrAddress encodeModRMWithOpcode: reg valueLow immediate: immediateSize longMode: longMode into: writer
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> encodeRexRM: rm [
	| bbit xbit lowBits |
	bbit := (rm base isNotNil and: [ rm base isHighRegister ]) asBit.
	xbit := (rm index isNotNil and: [ rm index isHighRegister ]) asBit.
	lowBits := (xbit << 1) | (bbit).
	
	lowBits ~= 0 ifTrue: [ 
		self assert: longMode.
		writer putInt8: 16r40 | lowBits
	]
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> encodeRexReg: reg [
	reg isHighRegister ifTrue: [ 
		self assert: longMode.
		writer putInt8: 16r44
	]
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> encodeRexSize: size rm: first reg: second [
	| wbit rbit xbit bbit lowBits |
	wbit := (size = 8) asBit.
	rbit := 0.
	xbit := 0.
	bbit := 0.
	first isRegisterOrRegisterAddress  ifTrue: [ 
		first isRegister ifTrue: [
			bbit := first isHighRegister asBit
		] ifFalse: [
			bbit := (first base isNotNil and: [ first base isHighRegister ]) asBit.
			xbit := (first index isNotNil and: [ first index isHighRegister ]) asBit.
		]
	].

	second isRegister ifTrue: [
		rbit := second isHighRegister asBit.
	].

	lowBits := (wbit << 3) | (rbit << 2) | (xbit << 1) | (bbit).
	lowBits ~= 0 ifTrue: [ 
		self assert: longMode.
		writer putInt8: 16r40 | lowBits
	]
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
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r04; putInt8: second value ].
			writer put: 16r80.
			self encodeModRM: first opcode: 0 immediate: 1.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r00.
			^ self encodeModRM: first reg: second
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				self encodeModRM: first opcode: 0 immediate: 1.
				^ writer putInt8: second value
			] ifFalse: [ 
				first == AX ifTrue: [ ^ writer put: 16r05; putInt16: second value ].
				writer put: 16r81.
				self encodeModRM: first opcode: 0 immediate: 2.
				^ writer putInt16: second value.
			]
		].
	
		second isRegister ifTrue: [
			writer put: 16r01.
			^ self encodeModRM: first reg: second.
		]
	].

	operandSize <= 8 ifTrue: [
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				self encodeModRM: first opcode: 0 immediate: 1.
				^ writer putInt8: second value
			] ifFalse: [ 
				first value = 0 ifTrue: [ ^ writer put: 16r05; putInt32: second value ].
				writer put: 16r81.
				self encodeModRM: first opcode: 0 immediate: 4.
				^ writer putMaybeReloc32: second.
			]
		].

		second isRegister ifTrue: [
			writer put: 16r01.
			^ self encodeModRM: first reg: second.
		].
	].

	self invalidInstruction.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateADDSD: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegister.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.	
	writer put: 16rF2; put: 16r0F; put: 16r58.
	^ self encodeModRM: second reg: first.

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateADDSS: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegister.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.	
	writer put: 16rF3; put: 16r0F; put: 16r58.
	^ self encodeModRM: second reg: first.

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateAND: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.
	operandSize := first size.
	
	operandSize = 1 ifTrue: [
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r24; putInt8: second value ].
			writer put: 16r80.
			self encodeModRM: first opcode: 4 immediate: 1.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r20.
			^ self encodeModRM: first reg: second
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				self encodeModRM: first opcode: 4 immediate: 1.
				^ writer putInt8: second value
			] ifFalse: [ 
				first == AX ifTrue: [ ^ writer put: 16r25; putInt16: second value ].
				writer put: 16r81.
				self encodeModRM: first opcode: 4 immediate: 2.
				^ writer putInt16: second value.
			]
		].
	
		second isRegister ifTrue: [
			writer put: 16r21.
			^ self encodeModRM: first reg: second.
		]
	].

	operandSize <= 8 ifTrue: [
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				self encodeModRM: first opcode: 4 immediate: 1.
				^ writer putInt8: second value
			] ifFalse: [ 
				first value = 0 ifTrue: [ ^ writer put: 16r25; putInt32: second value ].
				writer put: 16r81.
				self encodeModRM: first opcode: 4 immediate: 4.
				^ writer putMaybeReloc32: second.
			]
		].

		second isRegister ifTrue: [
			writer put: 16r21.
			^ self encodeModRM: first reg: second.
		].
	].

	self invalidInstruction.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateCALL: instruction [
	| operand |
	operand := instruction first.

	operand isLabel ifTrue: [
		^ writer put: 16rE8; putNextIPRelativeLabel32: operand
	].

	operand isRegisterOrRegisterAddress ifTrue: [
		writer put: 16rFF.
		^ self encodeModRM: operand opcode: 2
	].

	self invalidInstruction.

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateCMP: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.
	operandSize := first size.
	
	operandSize = 1 ifTrue: [
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r3C; putInt8: second value ].
			writer put: 16r80.
			self encodeModRM: first opcode: 7 immediate: 1.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r38.
			^  self encodeModRM: first reg: second.
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			first == AX ifTrue: [ ^ writer put: 16r3D; putInt16: second value ].
			writer put: 16r81.
			self encodeModRM: first opcode: 7 immediate: 2.
			^ writer putInt16: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r39.
			^ self encodeModRM: first reg: second.
		]
	].

	operandSize <= 8 ifTrue: [
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			first value = 0 ifTrue: [ ^ writer put: 16r3D; putInt32: second value ].
			writer put: 16r81.
			self encodeModRM: first opcode: 7 immediate: 4.
			^ writer putMaybeReloc32: second.
		].
	
		second isRegister ifTrue: [
			writer put: 16r39.
			^ self encodeModRM: first reg: second.
		]
	].

	self invalidInstruction
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateCVTPD2PS: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegister.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.

	writer put: 16r66; put: 16r0F; put: 16r5A.
	^ self encodeModRM: second reg: first 

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateCVTPS2PD: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegister.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.

	writer put: 16r0F; put: 16r5A.
	^ self encodeModRM: second reg: first 

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateCVTSD2SS: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegister.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.

	writer put: 16rF2; put: 16r0F; put: 16r5A.
	^ self encodeModRM: second reg: first 

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateCVTSS2SD: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegister.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.

	writer put: 16rF3; put: 16r0F; put: 16r5A.
	^ self encodeModRM: second reg: first 

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateFLD: instruction [
	| operand operandSize |
	operand := instruction operands first.
	self assert: operand isRegisterOrRegisterAddress.
	
	operandSize := operand size.
	operandSize = 4 ifTrue: [
		self encodeRexRM: operand.
		writer put: 16rd9.
		^ self encodeModRM: operand opcode: 0 
	].
	operandSize = 8 ifTrue: [
		self encodeRexRM: operand.
		writer put: 16rdd.
		^ self encodeModRM: operand opcode: 0
	].

	self invalidInstruction.
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateFST: instruction [
	| operand operandSize |
	operand := instruction operands first.
	self assert: operand isRegisterOrRegisterAddress.
	
	operandSize := operand size.
	operandSize = 4 ifTrue: [
		self encodeRexRM: operand.
		writer put: 16rd9.
		^ self encodeModRM: operand opcode: 2 
	].
	operandSize = 8 ifTrue: [
		self encodeRexRM: operand.
		writer put: 16rdd.
		^ self encodeModRM: operand opcode: 2
	].

	self invalidInstruction.
]

{ #category : #translating }
SLVMX86MachineCodeGenerator >> generateInstruction: instruction output: output [
	instruction offset: output position.
	instruction isLabel ifTrue: [
		instruction alignment > 1 ifTrue: [
			instruction offset: (output position alignedTo: instruction alignment).
			[ output position < instruction offset ] whileTrue: [
				instruction type = #function ifTrue: [
					"NOP"
					writer putInt8: 16r90
				] ifFalse: [ 
					writer putInt8: 0.
				]
			]
		].
		writer recordLabel: instruction.
	].
					
	instruction isLabelContentEnd ifTrue: [
		writer recordLabelEnd: instruction label
	].

	instruction isLabelValue ifTrue: [
		instruction size = 4 ifTrue: [
			writer
				recordReloc32Into: instruction label;
				putInt32: instruction label offset + instruction labelOffset
		] ifFalse: [
			writer
				recordReloc64Into: instruction label;
				putInt64: instruction label offset + instruction labelOffset
		]
	].
					
	instruction isBlob ifTrue: [
		self writeBlob: instruction.
	].
	
	instruction isInstruction ifTrue: [
		self generateMachineCodeInstruction: instruction output: output
	].

	instruction size: output position - instruction offset.	
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJA: instruction [
	^ self generateJCC: instruction opcode8: 16r77 opcode32: 16r87
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJBE: instruction [
	^ self generateJCC: instruction opcode8: 16r76 opcode32: 16r86
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
SLVMX86MachineCodeGenerator >> generateJE: instruction [
	^ self generateJCC: instruction opcode8: 16r74 opcode32: 16r84
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
	| operand |
	operand := instruction first.

	operand isLabel ifTrue: [
		(operand isExternalLabel not and: [self isInShortRange: operand offset - (writer position + 2)]) ifTrue: [
			^ writer put: 16rEB; putNextIPRelativeLabel8: operand
		] ifFalse: [ 
			^ writer put: 16rE9; putNextIPRelativeLabel32: operand
		]
	].

	operand isRegisterOrRegisterAddress ifTrue: [ 
		writer put: 16rFF.
		^ self encodeModRM: operand opcode: 4
	].

	self invalidInstruction.

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateJNE: instruction [
	^ self generateJCC: instruction opcode8: 16r75 opcode32: 16r85
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
			writer put: 16r66.
			writer put: 16rB8 + first value; putInt16: second value
		].
		operandSize = 4 ifTrue: [
			writer put: 16rB8 + first value; putMaybeReloc32: second
		].
		operandSize = 8 ifTrue: [
			(self isInInt32Range: second) ifTrue: [
				self encodeRexSize: operandSize rm: first reg: second.
				writer put: 16rC7.
				self encodeModRM: first opcode: 0 immediate: 4.
				writer putMaybeReloc32: second.  
			] ifFalse: [ 
				self encodeRexSize: operandSize rm: first reg: second.
				writer put: 16rB8 + first valueLow; putMaybeReloc64: second
			]
		].
		^ self
	].
	
	(first isRegisterOrRegisterAddress and: [ second isImmediate ]) ifTrue: [
		operandSize := first size.

		operandSize = 2 ifTrue: [
			writer put: 16r66.
		].
		
		self encodeRexSize: operandSize rm: first reg: second.
		operandSize = 1 ifTrue: [ writer put: 16rC6 ].
		operandSize <= 8 ifTrue: [ writer put: 16rC7 ].
		self encodeModRM: first opcode: 0 immediate: (operandSize min: 4).
		
		operandSize = 1 ifTrue: [ writer put: second value ].
		operandSize = 2 ifTrue: [ writer putInt16: second value ].
		operandSize <= 8 ifTrue: [ writer putMaybeReloc32: second value ].
		^ self
	].
 
	(first isRegisterOrRegisterAddress and: [ second isRegister ]) ifTrue: [
		self encodeRexSize: first size rm: first reg: second.
		writer put: 16r89.
		^ self encodeModRM: first reg: second.
	].

	(first isRegister and: [ second isRegisterOrRegisterAddress ]) ifTrue: [
		self encodeRexSize: first size rm: second reg: first.
		writer put: 16r8B.
		^ self encodeModRM: second reg: first.
	].

	self invalidInstruction
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateMOVAPD: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegisterOrRegisterAddress.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.
	
	second isRegisterAddress ifTrue: [
		writer put: 16r66; put: 16r0F; put: 16r28.
		^ self encodeModRM: second reg: first 
	].
	writer put: 16r66; put: 16r0F; put: 16r29.
	^ self encodeModRM: first reg: second.

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateMOVSD: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegisterOrRegisterAddress.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.
	
	second isRegisterAddress ifTrue: [
		writer put: 16rF2; put: 16r0F; put: 16r10.
		^ self encodeModRM: second reg: first 
	].
	writer put: 16rF2; put: 16r0F; put: 16r11.
	^ self encodeModRM: first reg: second.

]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateMOVSS: instruction [
	| first second |
	first := instruction first.
	second := instruction second.
	self assert: first isRegisterOrRegisterAddress.
	self assert: second isRegisterOrRegisterAddress.
	self encodeRexSize: 4 rm: first reg: second.
	
	second isRegisterAddress ifTrue: [
		writer put: 16rF3; put: 16r0F; put: 16r10.
		^ self encodeModRM: second reg: first 
	].
	writer put: 16rF3; put: 16r0F; put: 16r11.
	^ self encodeModRM: first reg: second.

]

{ #category : #translating }
SLVMX86MachineCodeGenerator >> generateMachineCodeInstruction: instruction output: output [
	| selector |
	selector := InstructionOpcodeGeneratorMap at: instruction opcode.
	self perform: selector with: instruction. 	
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generatePOP: instruction [
	| operand |
	operand := instruction first.
	operand isRegister ifTrue: [
		self encodeRexReg: operand.
		^ writer put: 16r58 + operand valueLow.
	].

	operand isRegisterOrRegisterAddress ifTrue: [
		self encodeRexRM: operand.
		writer put: 16r8F.
		^ self encodeModRM: operand opcode: 0.
	].

	self invalidInstruction
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generatePUSH: instruction [
	| operand |
	operand := instruction first.
	operand isImmediate ifTrue: [
		operand isSmallImmediate ifTrue: [
			^ writer put: 16r6A; putInt8: operand value.
		] ifFalse: [
			^ writer put: 16r68; putMaybeReloc32: operand.
		]
	].

	operand isRegister ifTrue: [
		self encodeRexReg: operand.
		^ writer put: 16r50 + operand valueLow.
	].

	operand isRegisterOrRegisterAddress ifTrue: [
		self encodeRexRM: operand.
		writer put: 16rFF.
		^ self encodeModRM: operand opcode: 6.
	].

	self invalidInstruction
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateRET: instruction [
	instruction operands ifEmpty: [ 
		writer put: 16rC3
	] ifNotEmpty: [
		self assert: instruction first isImmediate.
		writer put: 16rC2; putInt16: instruction first value
	]
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> generateSUB: instruction [
	| first second operandSize |
	first := instruction first.
	second := instruction second.
	operandSize := first size.
	
	operandSize = 1 ifTrue: [
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r2C; putInt8: second value ].
			writer put: 16r80.
			self encodeModRM: first opcode: 5 immediate: 1.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r28.
			^ self encodeModRM: first reg: second.
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				self encodeModRM: first opcode: 5 immediate: 1.
				^ writer putInt8: second value
			] ifFalse: [ 
				first == AX ifTrue: [ ^ writer put: 16r2D; putInt16: second value ].
				writer put: 16r81.
				self encodeModRM: first opcode: 5 immediate: 2.
				^ writer putInt16: second value.
			]
		].
	
		second isRegister ifTrue: [
			writer put: 16r29.
			^ self encodeModRM: first reg: second.
		]
	].

	operandSize <= 8 ifTrue: [
		self encodeRexSize: operandSize rm: first reg: second. 
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				self encodeModRM: first opcode: 5 immediate: 1.
				^ writer putInt8: second value
			] ifFalse: [ 
				first value = 0 ifTrue: [ ^ writer put: 16r2D; putInt32: second value ].
				writer put: 16r81.
				self encodeModRM: first opcode: 5 immediate: 4.
				^ writer putMaybeReloc32: second.
			]
		].

		second isRegister ifTrue: [
			writer put: 16r29.
			^ self encodeModRM: first reg: second
		].
	].

	self invalidInstruction
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
			self encodeModRM: first opcode: 0 immediate: 1.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r84.
			^ self encodeModRM: first reg: second
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		second isImmediate ifTrue: [
			first == AX ifTrue: [ ^ writer put: 16rA9; putInt16: second value ].
			writer put: 16rF7.
			self encodeModRM: first opcode: 0 immediate: 2.
			^ writer putInt16: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r85.
			^ self encodeModRM: first reg: second
		]
	].

	operandSize = 4 ifTrue: [
		second isImmediate ifTrue: [
			first == EAX ifTrue: [ ^ writer put: 16rA9; putInt32: second value ].
			writer put: 16rF7.
			self encodeModRM: first opcode: 0 immediate: 4.
			^ writer putInt32: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r85.
			^ self encodeModRM: first reg: second.
		]
	].

	self halt.
]

{ #category : #translating }
SLVMX86MachineCodeGenerator >> generateUntilConvergence [
	| result oldResult |
	oldResult := nil.
	[
		result := SLVMLirMachineCodeWriter do: [ :out |
			out compilationTarget: instructionStream compilationTarget.
			instructionStream sections do: [:section |
				out section: section alignment: self sectionAlignment do: [:sectionWriter |
					writer := sectionWriter.
					section instructionsDo: [ :ins |
						self generateInstruction: ins output: out
					]
				]
			]
		].
		oldResult = result ifTrue: [ ^ result compilationTarget: instructionStream compilationTarget ].
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
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			first == AL ifTrue: [ ^ writer put: 16r34; putInt8: second value ].
			writer put: 16r80.
			self encodeModRM: first opcode: 6 immediate: 1.
			^ writer putInt8: second value.
		].
	
		second isRegister ifTrue: [
			writer put: 16r30.
			^ self encodeModRM: first reg: second.
		]
	].

	operandSize = 2 ifTrue: [
		writer put: 16r66.
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				self encodeModRM: first opcode: 6 immediate: 1.
				^ writer putInt8: second value
			] ifFalse: [ 
				first == AX ifTrue: [ ^ writer put: 16r35; putInt16: second value ].
				writer put: 16r81.
				self encodeModRM: first opcode: 6 immediate: 2.
				^ writer putInt16: second value.
			]
		].
	
		second isRegister ifTrue: [
			writer put: 16r31.
			^ self encodeModRM: first reg: second.
		]
	].

	operandSize = 4 ifTrue: [
		self encodeRexSize: operandSize rm: first reg: second.
		second isImmediate ifTrue: [
			(self isInShortRange: second) ifTrue: [ 
				writer put: 16r83.
				self encodeModRM: first opcode: 6 immediate: 1.
				^ writer putInt8: second value
			] ifFalse: [ 
				first value = 0 ifTrue: [ ^ writer put: 16r35; putInt32: second value ].
				writer put: 16r81.
				self encodeModRM: first opcode: 6 immediate: 4.
				^ writer putMaybeReloc32: second.
			]
		].

		second isRegister ifTrue: [
			writer put: 16r31.
			^ self encodeModRM: first reg: second.
		].
	].

	self invalidInstruction
]

{ #category : #initialization }
SLVMX86MachineCodeGenerator >> initialize [
	super initialize.
	longMode := false.
	
]

{ #category : #'as yet unclassified' }
SLVMX86MachineCodeGenerator >> invalidInstruction [
	self error: 'Trying to generate an invalid instruction'
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> isInInt32Range: value [
	value isInteger ifTrue: [ ^ value between: -2147483648 and: 2147483647 ].
	^ value isImmediateInInt32Range
]

{ #category : #'instruction generation' }
SLVMX86MachineCodeGenerator >> isInShortRange: value [
	value isInteger ifTrue: [ ^ value between: -128 and: 127 ].
	^ value isSmallImmediate
]

{ #category : #accessing }
SLVMX86MachineCodeGenerator >> longMode [
	^ longMode
]

{ #category : #accessing }
SLVMX86MachineCodeGenerator >> longMode: anObject [
	longMode := anObject
]

{ #category : #translating }
SLVMX86MachineCodeGenerator >> sectionAlignment [
	^ 4096
]

{ #category : #translating }
SLVMX86MachineCodeGenerator >> writeBlob: blob [
	| mappedSymbols symbol mappedReloc |
	writer nextPutAll: blob content.
	blob relocations ifEmpty: [ ^ self ].
	
	mappedSymbols := IdentityDictionary new.
	blob relocations do: [ :reloc |
		symbol := nil.
		reloc symbol ifNotNil: [
			reloc symbol isLabel ifTrue: [ 
				symbol := writer symbolForLabel: reloc symbol.
			] ifFalse: [
				symbol := mappedSymbols at: reloc symbol ifAbsentPut: [
					writer addSymbol: reloc symbol
				]
			]
		].
	
		mappedReloc := reloc copy
			symbol: ((symbol isNotNil and: [ symbol shouldBeKeep ]) ifTrue: [ symbol ] ifFalse: [nil]);
			section: (symbol ifNotNil: [symbol section] ifNil: [writer currentSection]).
			
		"Use the unkept symbol as the addend."
		(symbol isNotNil and: [mappedReloc symbol isNil and: [ mappedReloc section ~~ writer currentSection]]) ifTrue: [ 
			mappedReloc addend: symbol.
		].
	
		writer currentSection addRelocation: mappedReloc
	]
]
