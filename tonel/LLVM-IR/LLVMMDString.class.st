Class {
	#name : #LLVMMDString,
	#superclass : #LLVMMetadata,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #printing }
LLVMMDString >> printOn: aStream [
	aStream nextPut: $!.
	value llvmPrintEscapedStringOn: aStream
]

{ #category : #accessing }
LLVMMDString >> value [
	^ value
]

{ #category : #accessing }
LLVMMDString >> value: anObject [
	value := anObject
]
