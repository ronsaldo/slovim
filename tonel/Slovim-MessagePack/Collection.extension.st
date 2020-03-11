Extension { #name : #Collection }

{ #category : #'*Slovim-MessagePack' }
Collection >> asSLVMMessagePackSerializableObject [
	^ self asArray
]
