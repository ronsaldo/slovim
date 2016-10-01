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
			self mapOperand: op
			replaceModuleElementsWith: moduleElementDictionary
			replaceBlocksWith: blockLabelDictionary
			lowerVariablesWith: lirFunction
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

{ #category : #copying }
SLVMLirInstruction >> mapOperand: operand replaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction [
	operand isNumber ifTrue: [ ^ operand ].
	
	operand isDynamicObjectSection ifTrue: [
		^ moduleElementDictionary at: operand
	].

	operand isLabelValue ifTrue: [ 
		 ^ operand copy label: (self mapOperand: operand label replaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction)
	].

	(operand isBasicBlock or: [ operand isLabel ]) ifTrue: [
		^blockLabelDictionary at: operand
	].
	operand isModuleElement ifTrue: [
		^ moduleElementDictionary at: operand
	].
	operand isStackFrameVariable ifTrue: [
		^ lirFunction lowerVariable: operand.
	].

	^ operand
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
