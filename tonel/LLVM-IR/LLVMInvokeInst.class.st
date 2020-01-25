Class {
	#name : #LLVMInvokeInst,
	#superclass : #LLVMTerminatorInst,
	#instVars : [
		'calledFunction',
		'arguments',
		'callingConvention',
		'normalDestination',
		'unwindDestination'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMInvokeInst >> arguments [
	^ arguments
]

{ #category : #accessing }
LLVMInvokeInst >> arguments: anObject [
	arguments := anObject
]

{ #category : #accessing }
LLVMInvokeInst >> calledFunction [
	^ calledFunction
]

{ #category : #accessing }
LLVMInvokeInst >> calledFunction: anObject [
	calledFunction := anObject
]

{ #category : #accessing }
LLVMInvokeInst >> callingConvention [
	^ callingConvention
]

{ #category : #accessing }
LLVMInvokeInst >> callingConvention: anObject [
	callingConvention := anObject
]

{ #category : #printing }
LLVMInvokeInst >> mnemonic [
	^ #invoke
]

{ #category : #accessing }
LLVMInvokeInst >> normalDestination [
	^ normalDestination
]

{ #category : #accessing }
LLVMInvokeInst >> normalDestination: anObject [
	normalDestination := anObject
]

{ #category : #printing }
LLVMInvokeInst >> printParametersOn: aStream [
	| calledFunctionType |
	callingConvention ifNotNil: [ aStream space; nextPutAll: callingConvention ].
	calledFunctionType := calledFunction type elementType.
	aStream space; print: calledFunctionType; space; print: calledFunction; nextPut: $(.
	arguments doWithIndex: [ :arg :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: arg type; space; print: arg
	].

	aStream nextPut: $).
	
	aStream nextPutAll: ' to '; print: normalDestination; nextPutAll: ' unwind '; print: unwindDestination
]

{ #category : #accessing }
LLVMInvokeInst >> unwindDestination [
	^ unwindDestination
]

{ #category : #accessing }
LLVMInvokeInst >> unwindDestination: anObject [
	unwindDestination := anObject
]
