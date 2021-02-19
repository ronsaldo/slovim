Extension { #name : #ByteSymbol }

{ #category : #'*LLVM-IR' }
ByteSymbol >> tfPointerAddress [

	self pinInMemory.
	^ PointerUtils oopForObject: self

]
