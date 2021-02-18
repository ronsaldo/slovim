Class {
	#name : #LLVMConstantAsMetadata,
	#superclass : #LLVMValueAsMetadata,
	#instVars : [
		'constant'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMConstantAsMetadata >> buildHandle [
	handle := constant validHandle asMetadata
]

{ #category : #accessing }
LLVMConstantAsMetadata >> constant [
	^ constant
]

{ #category : #accessing }
LLVMConstantAsMetadata >> constant: anObject [
	constant := anObject
]

{ #category : #printing }
LLVMConstantAsMetadata >> llvmPrintSpecializedMetadataValueOn: aStream [
	self printOn: aStream
	
]

{ #category : #printing }
LLVMConstantAsMetadata >> printOn: aStream [
	aStream print: constant type; space; print: constant
]
