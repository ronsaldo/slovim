Extension { #name : #FLEncoder }

{ #category : #'*Slovim-Runtime' }
FLEncoder >> encodeSLVMInternalStructure: internalStructure [
	stream nextBytesPutAll: internalStructure
]
