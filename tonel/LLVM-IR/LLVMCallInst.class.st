Class {
	#name : #LLVMCallInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'calledFunction',
		'arguments'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMCallInst >> arguments [
	^ arguments
]

{ #category : #accessing }
LLVMCallInst >> arguments: anObject [
	arguments := anObject
]

{ #category : #accessing }
LLVMCallInst >> calledFunction [
	^ calledFunction
]

{ #category : #accessing }
LLVMCallInst >> calledFunction: anObject [
	calledFunction := anObject
]

{ #category : #printing }
LLVMCallInst >> mnemonic [
	^ #call
]

{ #category : #printing }
LLVMCallInst >> printParametersOn: aStream [
	| calledFunctionType |
	calledFunctionType := calledFunction type elementType.
	aStream space; print: calledFunctionType; space; print: calledFunction; nextPut: $(.
	arguments doWithIndex: [ :arg :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: arg type; space; print: arg
	].

	aStream nextPut: $)
]
