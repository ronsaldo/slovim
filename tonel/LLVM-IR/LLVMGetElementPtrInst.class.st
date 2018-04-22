Class {
	#name : #LLVMGetElementPtrInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'pointer',
		'indices'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMGetElementPtrInst >> indices [
	^ indices
]

{ #category : #accessing }
LLVMGetElementPtrInst >> indices: anObject [
	indices := anObject
]

{ #category : #printing }
LLVMGetElementPtrInst >> mnemonic [
	^ #getelementptr
]

{ #category : #accessing }
LLVMGetElementPtrInst >> pointer [
	^ pointer
]

{ #category : #accessing }
LLVMGetElementPtrInst >> pointer: anObject [
	pointer := anObject
]

{ #category : #printing }
LLVMGetElementPtrInst >> printParametersOn: aStream [
	aStream space; print: pointer type elementType; nextPutAll: ', '; print: pointer type; space; print: pointer.
	indices do: [ :index |
		aStream nextPutAll: ', '; print: index type; space; print: index
	]
]
