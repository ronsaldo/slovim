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
SLVMLirInstruction >> copyReplaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction [
	| result |
	result := self copy.
	result operands: (operands collect: [ :op |
		(op isBasicBlock or: [ op isLabel ]) ifTrue: [
			blockLabelDictionary at: op
		] ifFalse: [
			op isModuleElement ifTrue: [
				moduleElementDictionary at: op
			] ifFalse: [
				op isStackFrameVariable ifTrue: [
					lirFunction lowerVariable: op
				] ifFalse: [
					op
				]
			]
		]
	]).
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
