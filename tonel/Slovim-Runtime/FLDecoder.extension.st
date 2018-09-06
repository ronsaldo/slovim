Extension { #name : #FLDecoder }

{ #category : #'*Slovim-Runtime' }
FLDecoder >> nextEncodedSLVMInternalStructureOfType: internalStructureClass [
	| result |
	result := internalStructureClass basicNew.
	result readBytesFromStream: stream.
	^ result
]
