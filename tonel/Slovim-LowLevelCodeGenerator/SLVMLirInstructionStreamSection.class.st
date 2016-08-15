Class {
	#name : #SLVMLirInstructionStreamSection,
	#superclass : #Object,
	#instVars : [
		'name',
		'compilationTarget',
		'firstInstruction',
		'lastInstruction'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'adding/removing' }
SLVMLirInstructionStreamSection >> add: element [
	self addLast: element
]

{ #category : #'adding/removing' }
SLVMLirInstructionStreamSection >> addLast: element [
	element
		stream: self;
		previous: lastInstruction;
		next: nil.
		
	lastInstruction ifNil: [ 
		lastInstruction := firstInstruction := element
	] ifNotNil: [ 
		lastInstruction next: element.
		lastInstruction := element
	]
]

{ #category : #accessing }
SLVMLirInstructionStreamSection >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirInstructionStreamSection >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #initialization }
SLVMLirInstructionStreamSection >> initialize [
	super initialize.
]

{ #category : #printing }
SLVMLirInstructionStreamSection >> instructionsDo: aBlock [
	| current instruction |
	current := firstInstruction.
	[ current isNotNil ] whileTrue: [ 
		instruction := current.
		current := current next.
		aBlock value: instruction.
	]
	
]

{ #category : #accessing }
SLVMLirInstructionStreamSection >> name [
	^ name
]

{ #category : #accessing }
SLVMLirInstructionStreamSection >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMLirInstructionStreamSection >> printOn: aStream [
	aStream nextPutAll: '.section '; nextPutAll: name; cr.
	self instructionsDo: [ :ins | ins printOnInstructionStream: aStream. aStream cr ]
]

{ #category : #'adding/removing' }
SLVMLirInstructionStreamSection >> removeElement: anElement [
	anElement previous ifNotNil: [ 
		anElement previous next: anElement next.
	] ifNil: [ 
		firstInstruction := anElement next.
	].

	anElement next ifNotNil: [ 
		anElement next previous: anElement previous.
	] ifNil: [ 
		lastInstruction := anElement previous
	].

	anElement
		stream: nil;
		previous: nil;
		next: nil

]
