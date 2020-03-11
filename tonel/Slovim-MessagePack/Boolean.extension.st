Extension { #name : #Boolean }

{ #category : #'*Slovim-MessagePack' }
Boolean >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
Boolean >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeBoolean: self
]
