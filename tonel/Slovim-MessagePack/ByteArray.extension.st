Extension { #name : #ByteArray }

{ #category : #'*Slovim-MessagePack' }
ByteArray >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeByteArray: self
]
