Class {
	#name : #SpirVModule,
	#superclass : #Object,
	#instVars : [
		'idBound',
		'instructions'
	],
	#pools : [
		'SpirVConstants'
	],
	#category : #'Slovim-SpirV'
}

{ #category : #'as yet unclassified' }
SpirVModule class >> build: aBlock [
	^ self new build: aBlock
]

{ #category : #building }
SpirVModule >> addInstruction: anInstruction [
	instructions add: anInstruction
]

{ #category : #building }
SpirVModule >> addInstructions: aCollectionOfInstructions [
	instructions addAll: aCollectionOfInstructions
]

{ #category : #building }
SpirVModule >> bytes [
	^ ByteArray streamContents: [ :out | self writeOn: out ]
]

{ #category : #'stream out' }
SpirVModule >> emitOn: aStream [
	aStream nextPut: SpvMagicNumber;
		nextPut: 16r00010000;
		nextPut: 0;
		nextPut: idBound;
		nextPut: 0.
	instructions do: [ :ins | ins emitOn: aStream ].
]

{ #category : #initialization }
SpirVModule >> initialize [
	super initialize.
	idBound := 1.
	instructions := OrderedCollection new.
]

{ #category : #'id generation' }
SpirVModule >> newId [
	| result |
	result := idBound.
	idBound := result + 1.
	^ result
]

{ #category : #fileout }
SpirVModule >> saveTo: aFileReference [
	FileStream forceNewFileNamed: aFileReference asFileReference fullName do: [ :out |
		out binary.
		self writeOn: out
	]
]

{ #category : #building }
SpirVModule >> writeOn: aByteStream [
	self emitOn: (SpirVStream new out: aByteStream)
]