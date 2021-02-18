Class {
	#name : #LLVMResumeInst,
	#superclass : #LLVMTerminatorInst,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMResumeInst >> buildHandleWithBuilder: builder [
	handle := builder resume: value validHandle
]

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
