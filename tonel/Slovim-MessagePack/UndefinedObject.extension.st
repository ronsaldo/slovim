Extension { #name : #UndefinedObject }

{ #category : #'*Slovim-MessagePack' }
UndefinedObject >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
UndefinedObject >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeNil
]
