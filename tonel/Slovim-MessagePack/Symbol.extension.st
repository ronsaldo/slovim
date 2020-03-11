Extension { #name : #Symbol }

{ #category : #'*Slovim-MessagePack' }
Symbol >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeSymbol: self
]
