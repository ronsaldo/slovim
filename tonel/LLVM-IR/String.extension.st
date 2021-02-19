Extension { #name : #String }

{ #category : #'*LLVM-IR' }
String >> asLLVMMetadataInContext: aContext [
	^ LLVMMDString new context: aContext; value: self; yourself
]

{ #category : #'*LLVM-IR' }
String >> isLLVMAnon [
	^ self detect: [:c | c isDigit not] ifFound: [false] ifNone: [ true ]
]

{ #category : #'*LLVM-IR' }
String >> isValidLLVMSymbol [
	self isLLVMAnon ifTrue: [ ^ true ].
	self ifEmpty: [ ^ false ].
	self first isDigit ifTrue: [ ^ false ].
	self do: [ :c |
		(('._$' includes: c) or: [ c isAlphaNumeric ]) ifFalse: [ ^ false ].
	].
	^ true
]

{ #category : #'*LLVM-IR' }
String >> llvmNameForHandle [
	(self allSatisfy: [ :each | each isDigit ]) ifTrue: [ ^ '' ].
	^ self
]

{ #category : #'*LLVM-IR' }
String >> llvmNameString [
	self isValidLLVMSymbol ifTrue: [ ^ self ].
	^ ByteString streamContents: [ :out |
		self llvmPrintEscapedStringOn: out
	]
]

{ #category : #'*LLVM-IR' }
String >> llvmPrintEscapedStringOn: aStream [
	^ self llvmPrintEscapedStringOn: aStream addNull: false
]

{ #category : #'*LLVM-IR' }
String >> llvmPrintEscapedStringOn: aStream addNull: addNull [
	aStream nextPut: $".
	self do: [ :element |
		(Character space <= element and: [ element <= $~ and: [('\"' includes: element) not]]) ifTrue: [ 
			aStream nextPut: element
		] ifFalse: [
			aStream nextPut: $\; nextPutAll: (element asInteger printStringBase: 16 length: 2 padded: true)
		]
	].
	
	addNull ifTrue: [ aStream nextPutAll: '\00' ].
	aStream nextPut: $".

]

{ #category : #'*LLVM-IR' }
String >> llvmPrintNameOn: aStream [
	self isValidLLVMSymbol ifTrue: [
		aStream nextPutAll: self
	] ifFalse: [
		self llvmPrintEscapedStringOn: aStream
	]
]

{ #category : #'*LLVM-IR' }
String >> llvmPrintSpecializedMetadataValueOn: aStream [
	self llvmPrintEscapedStringOn: aStream
]
