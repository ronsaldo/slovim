Class {
	#name : #SLVMLirInstruction,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'opcode',
		'operands'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #copying }
SLVMLirInstruction >> copyReplaceBlocksWith: dictionary [
	| result |
	result := self copy.
	result operands: (operands collect: [ :op | (op class == SLVMLirBasicBlock or: [op isLabel ]) ifTrue: [ dictionary at: op ] ifFalse: [ op]]).
	^ result
]

{ #category : #accessing }
SLVMLirInstruction >> first [
	^ operands first
]

{ #category : #testing }
SLVMLirInstruction >> isInstruction [
	^ true
]

{ #category : #accessing }
SLVMLirInstruction >> opcode [
	^ opcode
]

{ #category : #accessing }
SLVMLirInstruction >> opcode: anObject [
	opcode := anObject
]

{ #category : #accessing }
SLVMLirInstruction >> operands [
	^ operands
]

{ #category : #accessing }
SLVMLirInstruction >> operands: anObject [
	operands := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirInstruction >> printOnInstructionStream: aStream [
	aStream tab.
	self printOn: aStream
]

{ #category : #accessing }
SLVMLirInstruction >> second [
	^ operands second
]
