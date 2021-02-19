Class {
	#name : #LLVMMDNull,
	#superclass : #LLVMMetadata,
	#category : #'LLVM-IR-Metadata'
}

{ #category : #printing }
LLVMMDNull >> printOn: aStream [
	aStream nextPutAll: 'null'
]

{ #category : #accessing }
LLVMMDNull >> validHandle [
	^ LLVMMetadataRef null
]
