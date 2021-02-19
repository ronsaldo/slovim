Extension { #name : #UndefinedObject }

{ #category : #'*LLVM-IR' }
UndefinedObject >> asLLVMMetadataInContext: aContext [
	^ aContext nullMetadata
]

{ #category : #'*LLVM-IR' }
UndefinedObject >> llvmNameForHandle [
	^ ''
]

{ #category : #'*LLVM-IR' }
UndefinedObject >> llvmPrintSpecializedMetadataValueOn: aStream [
	aStream nextPutAll: 'null'
]
