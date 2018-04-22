Class {
	#name : #LLVMConstantInt,
	#superclass : #LLVMConstantData,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstantInt >> printOn: aStream [
	type bits = 1 ifTrue: [
		aStream nextPutAll: (value = 0 ifTrue: ['false'] ifFalse: ['true']).
		^ self
	].

	aStream print: value
]

{ #category : #accessing }
LLVMConstantInt >> value [
	^ value
]

{ #category : #accessing }
LLVMConstantInt >> value: anObject [
	value := anObject
]
