Class {
	#name : #LLVMBinaryOperator,
	#superclass : #LLVMInstruction,
	#instVars : [
		'operation',
		'left',
		'right'
	],
	#category : #'LLVM-IR'
}

{ #category : #accessing }
LLVMBinaryOperator >> left [
	^ left
]

{ #category : #accessing }
LLVMBinaryOperator >> left: anObject [
	left := anObject
]

{ #category : #printing }
LLVMBinaryOperator >> mnemonic [
	^ operation
]

{ #category : #accessing }
LLVMBinaryOperator >> operation [
	^ operation
]

{ #category : #accessing }
LLVMBinaryOperator >> operation: anObject [
	operation := anObject
]

{ #category : #printing }
LLVMBinaryOperator >> printParametersOn: aStream [
	aStream space; print: type; space; print: left; nextPutAll: ', '; print: right
]

{ #category : #accessing }
LLVMBinaryOperator >> right [
	^ right
]

{ #category : #accessing }
LLVMBinaryOperator >> right: anObject [
	right := anObject
]
