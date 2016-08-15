Class {
	#name : #SLVMLirBasicBlock,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'name',
		'function',
		'instructions'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #adding }
SLVMLirBasicBlock >> addInstruction: anInstruction [
	^ instructions add: anInstruction
]

{ #category : #printing }
SLVMLirBasicBlock >> fullPrintOn: aStream [
	self printOn: aStream.
	aStream cr.
	instructions do: [ :ins | aStream tab. ins printOn: aStream. aStream cr ].
]

{ #category : #accessing }
SLVMLirBasicBlock >> function [
	^ function
]

{ #category : #accessing }
SLVMLirBasicBlock >> function: anObject [
	function := anObject
]

{ #category : #initialization }
SLVMLirBasicBlock >> initialize [
	super initialize.
	instructions := OrderedCollection new.
]

{ #category : #accessing }
SLVMLirBasicBlock >> instructions [
	^ instructions
]

{ #category : #'as yet unclassified' }
SLVMLirBasicBlock >> isBasicBlock [
	^ true
]

{ #category : #accessing }
SLVMLirBasicBlock >> name [
	^ name
]

{ #category : #accessing }
SLVMLirBasicBlock >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMLirBasicBlock >> printOn: aStream [
	aStream nextPutAll: '.L'; nextPutAll: name
]
