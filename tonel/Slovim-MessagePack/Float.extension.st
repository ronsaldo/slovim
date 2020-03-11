Extension { #name : #Float }

{ #category : #'*Slovim-MessagePack' }
Float >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
Float >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeFloat: self
]
