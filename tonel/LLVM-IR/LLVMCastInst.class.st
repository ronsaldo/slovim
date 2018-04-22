Class {
	#name : #LLVMCastInst,
	#superclass : #LLVMUnaryInstruction,
	#instVars : [
		'source'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMCastInst >> printParametersOn: aStream [
	aStream space; print: source type; space; print: source; nextPutAll: ' to '; print: type
]

{ #category : #accessing }
LLVMCastInst >> source [
	^ source
]

{ #category : #accessing }
LLVMCastInst >> source: anObject [
	source := anObject
]
