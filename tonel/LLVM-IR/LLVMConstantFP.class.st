Class {
	#name : #LLVMConstantFP,
	#superclass : #LLVMConstantData,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstantFP >> printOn: aStream [
	aStream print: value
]

{ #category : #accessing }
LLVMConstantFP >> value [
	^ value
]

{ #category : #accessing }
LLVMConstantFP >> value: anObject [
	value := anObject
]
