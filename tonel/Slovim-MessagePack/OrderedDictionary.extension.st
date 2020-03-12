Extension { #name : #OrderedDictionary }

{ #category : #'*Slovim-MessagePack' }
OrderedDictionary >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
OrderedDictionary >> slvmMessagePackEncodeWith: encoder [
	encoder encodeMap: self
]
