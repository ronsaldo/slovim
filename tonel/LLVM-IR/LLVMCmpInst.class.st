Class {
	#name : #LLVMCmpInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'operation',
		'left',
		'right'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMCmpInst >> left [
	^ left
]

{ #category : #accessing }
LLVMCmpInst >> left: anObject [
	left := anObject
]

{ #category : #accessing }
LLVMCmpInst >> operation [
	^ operation
]

{ #category : #accessing }
LLVMCmpInst >> operation: anObject [
	operation := anObject
]

{ #category : #printing }
LLVMCmpInst >> printParametersOn: aStream [
	aStream space; nextPutAll: operation; space; print: left type; space; print: left; nextPutAll: ', '; print: right
]

{ #category : #accessing }
LLVMCmpInst >> right [
	^ right
]

{ #category : #accessing }
LLVMCmpInst >> right: anObject [
	right := anObject
]
