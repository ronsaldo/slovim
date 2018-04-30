Class {
	#name : #LLVMMetadataAsValue,
	#superclass : #LLVMValue,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR'
}

{ #category : #printing }
LLVMMetadataAsValue >> printOn: aStream [
	^ value printOn: aStream
]

{ #category : #accessing }
LLVMMetadataAsValue >> value [
	^ value
]

{ #category : #accessing }
LLVMMetadataAsValue >> value: anObject [
	value := anObject
]
