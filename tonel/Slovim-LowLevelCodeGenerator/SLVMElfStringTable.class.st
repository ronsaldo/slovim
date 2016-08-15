Class {
	#name : #SLVMElfStringTable,
	#superclass : #SLVMLirBinaryFileComponent,
	#instVars : [
		'outputOffset',
		'content',
		'stringDictionary'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #adding }
SLVMElfStringTable >> addString: aString [
	| result |
	^ stringDictionary at: aString ifAbsentPut: [ 
		result := content position.
		aString do: [ :char | content nextPut: char asInteger ].
		content nextPut: 0.
		result
	]
]

{ #category : #accessing }
SLVMElfStringTable >> contents [
	^ content contents
]

{ #category : #initialization }
SLVMElfStringTable >> initialize [
	super initialize.
	content := WriteStream on: (ByteArray new: 100).
	stringDictionary := Dictionary new.
	self addString: ''.
]

{ #category : #accessing }
SLVMElfStringTable >> size [
	^ content size
]

{ #category : #'as yet unclassified' }
SLVMElfStringTable >> writeOn: aStream [
	aStream nextPutAll: self contents
]
