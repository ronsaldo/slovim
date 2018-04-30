Extension { #name : #String }

{ #category : #'*LLVM-IR' }
String >> asLLVMMetadata [
	^ LLVMMDString new value: self
]

{ #category : #'*LLVM-IR' }
String >> isLLVMAnon [
	^ self detect: [:c | c isDigit not] ifFound: [false] ifNone: [ true ]
]

{ #category : #'*LLVM-IR' }
String >> llvmPrintEscapedStringOn: aStream [
	^ self llvmPrintEscapedStringOn: aStream addNull: false
]

{ #category : #'*LLVM-IR' }
String >> llvmPrintEscapedStringOn: aStream addNull: addNull [
	aStream nextPut: $".
	self do: [ :element |
		(Character space <= element and: [ element <= $~ and: [element ~~ $\]]) ifTrue: [ 
			aStream nextPut: element
		] ifFalse: [
			aStream nextPut: $\; nextPutAll: (element asInteger printStringBase: 16 length: 2 padded: true)
		]
	].
	
	addNull ifTrue: [ aStream nextPutAll: '\00' ].
	aStream nextPut: $".

]

{ #category : #'*LLVM-IR' }
String >> llvmPrintSpecializedMetadataValueOn: aStream [
	self llvmPrintEscapedStringOn: aStream
]
