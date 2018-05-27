Class {
	#name : #LLVMInsertElementInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'element',
		'elementIndex',
		'vector'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMInsertElementInst >> element [
	^ element
]

{ #category : #accessing }
LLVMInsertElementInst >> element: anObject [
	element := anObject
]

{ #category : #accessing }
LLVMInsertElementInst >> elementIndex [
	^ elementIndex
]

{ #category : #accessing }
LLVMInsertElementInst >> elementIndex: anObject [
	elementIndex := anObject
]

{ #category : #printing }
LLVMInsertElementInst >> mnemonic [
	^ #insertelement
]

{ #category : #printing }
LLVMInsertElementInst >> printParametersOn: aStream [
	aStream space; print: type; space; print: vector;
		nextPutAll: ', '; print: element type; space; print: element;
		nextPutAll: ', '; print: elementIndex type; space; print: elementIndex
]

{ #category : #accessing }
LLVMInsertElementInst >> vector [
	^ vector
]

{ #category : #accessing }
LLVMInsertElementInst >> vector: anObject [
	vector := anObject
]
