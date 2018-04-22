Class {
	#name : #LLVMAllocaInst,
	#superclass : #LLVMUnaryInstruction,
	#instVars : [
		'valueType'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMAllocaInst >> mnemonic [
	^ #alloca
]

{ #category : #printing }
LLVMAllocaInst >> printParametersOn: aStream [
	aStream space; print: valueType
]

{ #category : #accessing }
LLVMAllocaInst >> valueType [
	^ valueType
]

{ #category : #accessing }
LLVMAllocaInst >> valueType: anObject [
	valueType := anObject
]
