Extension { #name : #String }

{ #category : #'*LLVM-IR' }
String >> isLLVMAnon [
	^ self detect: [:c | c isDigit not] ifFound: [false] ifNone: [ true ]
]
