Class {
	#name : #SLVMLirX86Instruction,
	#superclass : #SLVMLirInstruction,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86Instruction >> mapOperand: operand replaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction [
	operand class == SLVMLirX86RegisterAddress ifTrue: [ 
		operand displacement ifNil: [ ^ operand ].
		^ operand copy displacement: (self mapOperand: operand displacement
			replaceModuleElementsWith: moduleElementDictionary
			replaceBlocksWith: blockLabelDictionary
			lowerVariablesWith: lirFunction)
	].

	^ super mapOperand: operand replaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction

]

{ #category : #printing }
SLVMLirX86Instruction >> printOn: aStream [
	| first |
	aStream nextPutAll: (InstructionOpcodeMnemonicMap at: opcode); space.
	first := true.
	operands do: [ :op |
		first ifFalse: [ aStream nextPutAll: ', '].
		first := false.
		aStream print: op
	]
]
