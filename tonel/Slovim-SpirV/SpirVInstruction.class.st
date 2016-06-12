Class {
	#name : #SpirVInstruction,
	#superclass : #Object,
	#instVars : [
		'opcode',
		'typeId',
		'resultId',
		'operands'
	],
	#category : #'Slovim-SpirV'
}

{ #category : #'as yet unclassified' }
SpirVInstruction class >> opcode: opcode [
	^ self new opcode: opcode
]

{ #category : #'as yet unclassified' }
SpirVInstruction class >> opcode: opcode operands: operands [
	^ self new opcode: opcode; operands: operands
]

{ #category : #'as yet unclassified' }
SpirVInstruction class >> opcode: opcode result: resultId [
	^ self new opcode: opcode; resultId: resultId
]

{ #category : #'as yet unclassified' }
SpirVInstruction class >> opcode: opcode result: resultId operands: operands [
	^ self new opcode: opcode; resultId: resultId; operands: operands
]

{ #category : #'as yet unclassified' }
SpirVInstruction class >> opcode: opcode type: typeId [
	^ self new opcode: opcode; typeId: typeId
]

{ #category : #'as yet unclassified' }
SpirVInstruction class >> opcode: opcode type: typeId result: resultId [
	^ self new opcode: opcode; typeId: typeId; resultId: resultId
]

{ #category : #'as yet unclassified' }
SpirVInstruction class >> opcode: opcode type: typeId result: resultId operands: operands [
	^ self new opcode: opcode; typeId: typeId; resultId: resultId; operands: operands
]

{ #category : #'stream out' }
SpirVInstruction >> emitOn: aWordStream [
	aWordStream nextPut: opcode | (self wordCount << 16).
	typeId ifNotNil: [ aWordStream nextPut: typeId ].
	resultId ifNotNil: [ aWordStream nextPut: resultId ].
	aWordStream nextPutAll: operands.
]

{ #category : #initialization }
SpirVInstruction >> initialize [
	super initialize.
	operands := #()
]

{ #category : #accessing }
SpirVInstruction >> opcode [
	^ opcode
]

{ #category : #accessing }
SpirVInstruction >> opcode: anObject [
	opcode := anObject
]

{ #category : #accessing }
SpirVInstruction >> operands [
	^ operands
]

{ #category : #accessing }
SpirVInstruction >> operands: anObject [
	operands := anObject
]

{ #category : #'as yet unclassified' }
SpirVInstruction >> printOn: aStream [
	aStream print: opcode
]

{ #category : #accessing }
SpirVInstruction >> resultId [
	^ resultId
]

{ #category : #accessing }
SpirVInstruction >> resultId: anObject [
	resultId := anObject
]

{ #category : #accessing }
SpirVInstruction >> typeId [
	^ typeId
]

{ #category : #accessing }
SpirVInstruction >> typeId: anObject [
	typeId := anObject
]

{ #category : #accessing }
SpirVInstruction >> wordCount [
	| wordCount |
	wordCount := 1.
	typeId ifNotNil: [ wordCount := wordCount + 1 ].
	resultId ifNotNil: [ wordCount := wordCount + 1 ].
	wordCount := wordCount + operands size.
	^ wordCount
]
