Extension { #name : #SequenceableCollection }

{ #category : #'*Slovim-MessagePack' }
SequenceableCollection >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #'*Slovim-MessagePack' }
SequenceableCollection >> slvmMessagePackEncodeWith: encoder [
	^ encoder encodeArray: self
]
