Class {
	#name : #SLVMLirInstructionStream,
	#superclass : #Object,
	#instVars : [
		'compilationTarget',
		'firstInstruction',
		'lastInstruction'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'adding/removing' }
SLVMLirInstructionStream >> add: element [
	self addLast: element
]

{ #category : #'adding/removing' }
SLVMLirInstructionStream >> addLast: element [
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

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> asMachineCode [
	^ compilationTarget generateMachineCodeFromInstructionStream: self
]

{ #category : #accessing }
SLVMLirInstructionStream >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirInstructionStream >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #initialization }
SLVMLirInstructionStream >> initialize [
	super initialize.
	instructions := OrderedCollection new.
]

{ #category : #printing }
SLVMLirInstructionStream >> instructionsDo: aBlock [
	| current instruction |
	current := firstInstruction.
	[ current isNotNil ] whileTrue: [ 
		instruction := current.
		current := current next.
		aBlock value: instruction.
	]
	
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> optimize [
	compilationTarget optimizeLirStream: self
]

{ #category : #printing }
SLVMLirInstructionStream >> printOn: aStream [
	self instructionsDo: [ :ins | ins printOnInstructionStream: aStream. aStream cr ]
]

{ #category : #'adding/removing' }
SLVMLirInstructionStream >> removeElement: anElement [
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
