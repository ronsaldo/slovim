Extension { #name : #Number }

{ #category : #'*Slovim-MessagePack' }
Number >> asSLVMMessagePackSerializableObject [
	^ self asFloat
]
