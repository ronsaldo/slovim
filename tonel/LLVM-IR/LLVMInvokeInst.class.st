Class {
	#name : #LLVMInvokeInst,
	#superclass : #LLVMTerminatorInst,
	#instVars : [
		'calledFunction',
		'arguments',
		'argumentAttributes',
		'returnAttributes',
		'callingConvention',
		'normalDestination',
		'unwindDestination'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMInvokeInst >> argumentAttributes [
	^ argumentAttributes ifNil: [ argumentAttributes := arguments collect: [:each | #() ]]
]

{ #category : #accessing }
LLVMInvokeInst >> argumentAttributes: anObject [
	argumentAttributes := anObject
]

{ #category : #accessing }
LLVMInvokeInst >> arguments [
	^ arguments
]

{ #category : #accessing }
LLVMInvokeInst >> arguments: anObject [
	arguments := anObject
]

{ #category : #'as yet unclassified' }
LLVMInvokeInst >> buildHandleWithBuilder: builder [
	handle := builder invoke: calledFunction validHandle arguments: (LLVMValueRefArray withAll: arguments) getHandle count: arguments size thenBlock: normalDestination validHandle catchBlock: unwindDestination validHandle name: name llvmNameForHandle
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

	aStream nextPut: $).
	
	aStream nextPutAll: ' to label '; print: normalDestination; nextPutAll: ' unwind label '; print: unwindDestination
]

{ #category : #accessing }
LLVMInvokeInst >> returnAttributes [
	^ returnAttributes ifNil: [ returnAttributes := #() ]
]

{ #category : #accessing }
LLVMInvokeInst >> returnAttributes: anObject [
	returnAttributes := anObject
]

{ #category : #accessing }
LLVMInvokeInst >> unwindDestination [
	^ unwindDestination
]

{ #category : #accessing }
LLVMInvokeInst >> unwindDestination: anObject [
	unwindDestination := anObject
]
