Extension { #name : #UndefinedObject }

{ #category : #'*LLVM-IR' }
UndefinedObject >> asLLVMMetadata [
	^ LLVMMDNull new
]

{ #category : #'*LLVM-IR' }
UndefinedObject >> llvmNameForHandle [
	^ ''
]

{ #category : #'*LLVM-IR' }
UndefinedObject >> llvmPrintSpecializedMetadataValueOn: aStream [
	aStream nextPutAll: 'null'
]
