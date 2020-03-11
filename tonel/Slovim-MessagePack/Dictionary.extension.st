Extension { #name : #Dictionary }

{ #category : #'*Slovim-MessagePack' }
Dictionary >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
Dictionary >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeMap: self
]
