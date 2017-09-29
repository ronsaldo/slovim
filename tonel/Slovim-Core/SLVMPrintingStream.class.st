Class {
	#name : #SLVMPrintingStream,
	#superclass : #DecoratorStream,
	#instVars : [
		'tabCount',
		'startingLine'
	],
	#category : #'Slovim-Core-Printing'
}

{ #category : #'as yet unclassified' }
SLVMPrintingStream class >> fullPrintString: anObject [
	^ ByteString streamContents: [ :out | anObject fullPrintOn: (self on: out) ]
]

{ #category : #writing }
SLVMPrintingStream >> cr [
	decoratedStream cr.
	startingLine := true.
]

{ #category : #'code generation' }
SLVMPrintingStream >> emitTabs [
	1 to: tabCount do: [ :i | decoratedStream tab ]
]

{ #category : #initialization }
SLVMPrintingStream >> initialize [
	super initialize.
	tabCount := 0.
	startingLine := true.
]

{ #category : #writing }
SLVMPrintingStream >> lf [
	decoratedStream lf.
	startingLine := true.
]

{ #category : #accessing }
SLVMPrintingStream >> nextPut: aValue [
	startingLine ifTrue: [ 
		startingLine := false.
		self emitTabs.
	].
	^ decoratedStream nextPut: aValue
]

{ #category : #'syntax highlighting' }
SLVMPrintingStream >> putIdentifier: aString [
	self nextPutAll: aString
]

{ #category : #'syntax highlighting' }
SLVMPrintingStream >> putKeyword: aString [
	self nextPutAll: aString
]

{ #category : #'syntax highlighting' }
SLVMPrintingStream >> putNumber: aNumber [
	self print: aNumber
]

{ #category : #writing }
SLVMPrintingStream >> space [
	decoratedStream space
]

{ #category : #writing }
SLVMPrintingStream >> tab [
	decoratedStream tab.
	startingLine := true.
]

{ #category : #'code generation' }
SLVMPrintingStream >> withExtraIndentationLevel: aBlock [
	tabCount := tabCount + 1.
	aBlock ensure: [ tabCount := tabCount - 1 ].
]

{ #category : #'code generation' }
SLVMPrintingStream >> withLessIndentationLevel: aBlock [
	tabCount := tabCount - 1.
	aBlock ensure: [ tabCount := tabCount + 1 ].
]
