Extension { #name : #Character }

{ #category : #'*Slovim-MessagePack' }
Character >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
Character >> slvmMessagePackEncodeWith: encoder [
	encoder encodeCharacter: self
]
