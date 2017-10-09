Extension { #name : #Object }

{ #category : #'*Slovim-Runtime' }
Object >> asPointerToInternalObjectData [
	^ SLVMInternalObjectPointer object: self
]
