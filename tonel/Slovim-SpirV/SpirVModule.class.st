Class {
	#name : #SpirVModule,
	#superclass : #Object,
	#instVars : [
		'idBound',
		'instructions',
		'entryPoints'
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

{ #category : #accessing }
SpirVModule >> entryPoints [
	^ entryPoints
]

{ #category : #accessing }
SpirVModule >> entryPoints: anObject [
	entryPoints := anObject
]

{ #category : #initialization }
SpirVModule >> initialize [
	super initialize.
	idBound := 1.
	instructions := OrderedCollection new.
]

{ #category : #accessing }
SpirVModule >> linkerArguments: aListOfArguments [
	"This is ignored by this backend."
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

{ #category : #writing }
SpirVModule >> writeExecutableToFileNamed: fileName [
	^ self saveTo: fileName
]

{ #category : #writing }
SpirVModule >> writeObjectToFileNamed: fileName [
	^ self saveTo: fileName
]

{ #category : #building }
SpirVModule >> writeOn: aByteStream [
	self emitOn: (SpirVStream new out: aByteStream)
]

{ #category : #writing }
SpirVModule >> writePluginToFileNamed: fileName [
	^ self writeExecutableToFileNamed: fileName
]

{ #category : #writing }
SpirVModule >> writeSharedToFileNamed: fileName [
	^ self writeExecutableToFileNamed: fileName
]
