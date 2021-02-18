Class {
	#name : #LLVMExtractValueInst,
	#superclass : #LLVMUnaryInstruction,
	#instVars : [
		'aggregate',
		'indices'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMExtractValueInst >> aggregate [
	^ aggregate
]

{ #category : #accessing }
LLVMExtractValueInst >> aggregate: anObject [
	aggregate := anObject
]

{ #category : #'as yet unclassified' }
LLVMExtractValueInst >> buildHandleWithBuilder: builder [
	| currentAggregate |
	currentAggregate := aggregate validHandle.
	indices doWithIndex: [ :each :indexIndex |
		currentAggregate := builder extract: currentAggregate valueAt: each
			name: (indexIndex = indices size ifTrue: [ name llvmNameForHandle ] ifFalse: ['']).
	].
	handle := currentAggregate
]

{ #category : #'as yet unclassified' }
LLVMExtractValueInst >> computeResultType [
	| memberType |
	memberType := aggregate type.
	self assert: indices isEmpty not.
	indices do: [ :each |
		memberType := memberType memberAt: each
	].

	type := memberType
]

{ #category : #accessing }
LLVMExtractValueInst >> indices [
	^ indices
]

{ #category : #accessing }
LLVMExtractValueInst >> indices: anObject [
	indices := anObject
]

{ #category : #printing }
LLVMExtractValueInst >> mnemonic [
	^ #extractvalue
]

{ #category : #printing }
LLVMExtractValueInst >> printParametersOn: aStream [
	aStream space; print: aggregate type; space; print: aggregate.
	indices do: [ :index |
		aStream nextPutAll: ', '; print: index
	]
]
