Class {
	#name : #LLVMCallInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'calledFunction',
		'arguments',
		'argumentAttributes',
		'returnAttributes',
		'callingConvention'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMCallInst >> argumentAttributes [
	^ argumentAttributes ifNil: [ argumentAttributes := arguments collect: [:each | #() ]]
]

{ #category : #accessing }
LLVMCallInst >> argumentAttributes: anObject [
	argumentAttributes := anObject
]

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

{ #category : #accessing }
LLVMCallInst >> callingConvention [
	^ callingConvention
]

{ #category : #accessing }
LLVMCallInst >> callingConvention: anObject [
	callingConvention := anObject
]

{ #category : #printing }
LLVMCallInst >> mnemonic [
	^ #call
]

{ #category : #printing }
LLVMCallInst >> printParametersOn: aStream [
	| calledFunctionType |
	callingConvention ifNotNil: [ aStream space; nextPutAll: callingConvention ].
	returnAttributes ifNotNil: [ returnAttributes do: [ :each | aStream space; nextPutAll: each ] ].
	calledFunctionType := calledFunction type elementType.
	aStream space; print: calledFunctionType; space; print: calledFunction; nextPut: $(.
	arguments doWithIndex: [ :arg :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: arg type; space.
		argumentAttributes ifNotNil: [ (argumentAttributes at: index) do: [ :each |
			aStream nextPutAll: each; space
		] ].
		aStream print: arg
	].

	aStream nextPut: $)
]

{ #category : #accessing }
LLVMCallInst >> returnAttributes [
	^ returnAttributes ifNil: [ returnAttributes := #() ]
]

{ #category : #accessing }
LLVMCallInst >> returnAttributes: anObject [
	returnAttributes := anObject
]
