Class {
	#name : #LLVMLocalAsMetadata,
	#superclass : #LLVMValueAsMetadata,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #printing }
LLVMLocalAsMetadata >> printOn: aStream [
	aStream print: value type; space; print: value
]

{ #category : #accessing }
LLVMLocalAsMetadata >> value [
	^ value
]

{ #category : #accessing }
LLVMLocalAsMetadata >> value: anObject [
	value := anObject
]
