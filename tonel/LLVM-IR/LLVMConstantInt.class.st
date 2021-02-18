Class {
	#name : #LLVMConstantInt,
	#superclass : #LLVMConstantData,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMConstantInt >> buildHandle [
	handle := type validHandle constInt: value & 16rFFFFFFFFFFFFFFFF signExtend: value < 0
]

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
