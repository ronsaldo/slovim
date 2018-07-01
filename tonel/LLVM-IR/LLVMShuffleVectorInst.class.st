Class {
	#name : #LLVMShuffleVectorInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'firstVector',
		'secondVector',
		'mask'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMShuffleVectorInst >> firstVector [
	^ firstVector
]

{ #category : #accessing }
LLVMShuffleVectorInst >> firstVector: anObject [
	firstVector := anObject
]

{ #category : #accessing }
LLVMShuffleVectorInst >> mask [
	^ mask
]

{ #category : #accessing }
LLVMShuffleVectorInst >> mask: anObject [
	mask := anObject
]

{ #category : #printing }
LLVMShuffleVectorInst >> mnemonic [
	^ #shufflevector
]

{ #category : #printing }
LLVMShuffleVectorInst >> printParametersOn: aStream [
	aStream space; print: firstVector type; space; print: firstVector;
		nextPutAll: ', '; print: secondVector type; space; print: secondVector;
		nextPutAll: ', '; print: mask type; space; print: mask
]

{ #category : #accessing }
LLVMShuffleVectorInst >> secondVector [
	^ secondVector
]

{ #category : #accessing }
LLVMShuffleVectorInst >> secondVector: anObject [
	secondVector := anObject
]
