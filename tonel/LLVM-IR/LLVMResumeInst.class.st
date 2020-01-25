Class {
	#name : #LLVMResumeInst,
	#superclass : #LLVMTerminatorInst,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMResumeInst >> mnemonic [
	^ #resume
]

{ #category : #printing }
LLVMResumeInst >> printParametersOn: aStream [
	aStream space; print: value type; space; print: value
]

{ #category : #accessing }
LLVMResumeInst >> value [
	^ value
]

{ #category : #accessing }
LLVMResumeInst >> value: anObject [
	value := anObject
]
