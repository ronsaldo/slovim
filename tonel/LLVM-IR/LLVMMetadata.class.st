Class {
	#name : #LLVMMetadata,
	#superclass : #LLVMObject,
	#category : #'LLVM-IR-Metadata'
}

{ #category : #converting }
LLVMMetadata >> asLLVMMetadataInContext: aContext [
	^ self
]

{ #category : #converting }
LLVMMetadata >> asLLVMValueFor: context [
	^ LLVMMetadataAsValue new
		type: context metadataTy;
		value: self;
		yourself
	
]
