Class {
	#name : #LLVMExtractElementInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'vector',
		'index'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMExtractElementInst >> buildHandleWithBuilder: builder [
	handle := builder extract: vector validHandle elementAt: index validHandle name: name llvmNameForHandle
]

{ #category : #accessing }
LLVMExtractElementInst >> index [
	^ index
]

{ #category : #accessing }
LLVMExtractElementInst >> index: anObject [
	index := anObject
]

{ #category : #printing }
LLVMExtractElementInst >> mnemonic [
	^ #extractelement
]

{ #category : #printing }
LLVMExtractElementInst >> printParametersOn: aStream [
	aStream space; print: vector type; space; print: vector;
		nextPutAll: ', '; print: index type; space; print: index
]

{ #category : #accessing }
LLVMExtractElementInst >> vector [
	^ vector
]

{ #category : #accessing }
LLVMExtractElementInst >> vector: anObject [
	vector := anObject
]
