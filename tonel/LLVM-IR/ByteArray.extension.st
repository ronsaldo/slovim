Extension { #name : #ByteArray }

{ #category : #'*LLVM-IR' }
ByteArray >> llvmPrintEscapedStringOn: aStream addNull: addNull [
	| element |
	aStream nextPut: $".
	self do: [ :byte |
		element := byte asCharacter.
		(Character space <= element and: [ element <= $~ and: [element ~~ $\]]) ifTrue: [ 
			aStream nextPut: element
		] ifFalse: [
			aStream nextPut: $\; nextPutAll: (byte printStringBase: 16 length: 2 padded: true)
		]
	].
	
	addNull ifTrue: [ aStream nextPutAll: '\00' ].
	aStream nextPut: $".

]
