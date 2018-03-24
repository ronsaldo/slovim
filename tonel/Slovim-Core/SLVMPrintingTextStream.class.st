Class {
	#name : #SLVMPrintingTextStream,
	#superclass : #SLVMPrintingStream,
	#instVars : [
		'runs'
	],
	#classVars : [
		'IdentifierAttributes',
		'KeywordAttributes'
	],
	#category : #'Slovim-Core-Printing'
}

{ #category : #'as yet unclassified' }
SLVMPrintingTextStream class >> fullPrintString: anObject [
	| stream resultString |
	resultString := ByteString streamContents: [ :out |
		stream := self on: out.
		anObject fullPrintOn: stream.
	].
	stream fillWithDefaultAttributes.
	self assert: resultString size = stream runs size.
	^ Text string: resultString runs: stream runs
]

{ #category : #initialization }
SLVMPrintingTextStream class >> initialize [
	super initialize.
	IdentifierAttributes := {TextColor color: Color orange}.
	KeywordAttributes := {TextColor blue}.
]

{ #category : #'syntax highlighting' }
SLVMPrintingTextStream >> fillWithDefaultAttributes [
	runs add: #() withOccurrences: decoratedStream position - runs size
]

{ #category : #initialization }
SLVMPrintingTextStream >> initialize [
	super initialize.
	runs := RunArray new.
]

{ #category : #'syntax highlighting' }
SLVMPrintingTextStream >> putIdentifier: aString [
	self withAttributes: IdentifierAttributes do: [
		self nextPutAll: aString
	]
	
]

{ #category : #'syntax highlighting' }
SLVMPrintingTextStream >> putKeyword: aString [
	self withAttributes: KeywordAttributes do: [
		self nextPutAll: aString
	]
	
]

{ #category : #accessing }
SLVMPrintingTextStream >> runs [
	^ runs
]

{ #category : #'syntax highlighting' }
SLVMPrintingTextStream >> withAttributes: attributes do: aBlock [
	| startPosition endPosition usedCount |
	self fillWithDefaultAttributes.
	startPosition := decoratedStream position.
	aBlock value.
	endPosition := decoratedStream position.
	
	usedCount := endPosition - startPosition.
	runs add: attributes withOccurrences: usedCount
]
