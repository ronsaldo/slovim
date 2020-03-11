Extension { #name : #Integer }

{ #category : #'*Slovim-MessagePack' }
Integer >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
Integer >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeInteger: self
]
