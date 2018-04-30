Class {
	#name : #LLVMMetadata,
	#superclass : #LLVMObject,
	#category : #'LLVM-IR-Metadata'
}

{ #category : #converting }
LLVMMetadata >> asLLVMMetadata [
	^ self
]

{ #category : #converting }
LLVMMetadata >> asLLVMValueFor: context [
	^ LLVMMetadataAsValue new
		type: context metadataTy;
		value: self;
		yourself
	
]
