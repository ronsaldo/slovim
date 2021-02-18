Class {
	#name : #LLVMLocalAsMetadata,
	#superclass : #LLVMValueAsMetadata,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMLocalAsMetadata >> buildHandle [
	handle := value validHandle asMetadata
]

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
