Class {
	#name : #SLVMLirX86Instruction,
	#superclass : #SLVMLirInstruction,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

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
