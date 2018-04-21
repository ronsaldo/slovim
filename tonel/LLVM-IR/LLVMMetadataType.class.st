Class {
	#name : #LLVMMetadataType,
	#superclass : #LLVMOpaqueType,
	#category : #'LLVM-IR'
}

{ #category : #'as yet unclassified' }
LLVMMetadataType >> initialize [
	super initialize.
	self name: #metadata
]

{ #category : #testing }
LLVMMetadataType >> isMetadataTy [
	^ true
]
