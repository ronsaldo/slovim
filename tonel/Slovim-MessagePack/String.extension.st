Extension { #name : #String }

{ #category : #'*Slovim-MessagePack' }
String >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
String >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeString: self
]
