Class {
	#name : #SLVMPrintingTextStream,
	#superclass : #SLVMPrintingStream,
	#classVars : [
		'IdentifierColor',
		'KeywordColor'
	],
	#category : #'Slovim-Core-Printing'
}

{ #category : #initialization }
SLVMPrintingTextStream class >> fullPrintString: anObject [
	^ Text streamContents: [ :out | anObject fullPrintOn: (self on: out) ]
]

{ #category : #initialization }
SLVMPrintingTextStream class >> initialize [
	super initialize.
	IdentifierColor := TextColor color: Color orange.
	KeywordColor := TextColor blue.
]

{ #category : #'syntax highlighting' }
SLVMPrintingTextStream >> putIdentifier: aString [
	decoratedStream withAttribute: IdentifierColor do: [
		self nextPutAll: aString
	]
	
]

{ #category : #'syntax highlighting' }
SLVMPrintingTextStream >> putKeyword: aString [
	decoratedStream withAttribute: KeywordColor do: [
		self nextPutAll: aString
	]
	
]
