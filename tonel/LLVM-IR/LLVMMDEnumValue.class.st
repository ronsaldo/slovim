Class {
	#name : #LLVMMDEnumValue,
	#superclass : #LLVMMetadata,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #printing }
LLVMMDEnumValue >> llvmPrintSpecializedMetadataValueOn: aStream [
	aStream nextPutAll: value
]

{ #category : #accessing }
LLVMMDEnumValue >> value [
	^ value
]

{ #category : #accessing }
LLVMMDEnumValue >> value: anObject [
	value := anObject
]
