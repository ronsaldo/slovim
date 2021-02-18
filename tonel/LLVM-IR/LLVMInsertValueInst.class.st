Class {
	#name : #LLVMInsertValueInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'aggregate',
		'element',
		'indices'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMInsertValueInst >> aggregate [
	^ aggregate
]

{ #category : #accessing }
LLVMInsertValueInst >> aggregate: anObject [
	aggregate := anObject
]

{ #category : #'as yet unclassified' }
LLVMInsertValueInst >> buildHandleWithBuilder: builder [
	self assert: indices size = 1.
	handle := builder insert: aggregate validHandle value: element validHandle at: indices first name: name llvmNameForHandle
]

{ #category : #accessing }
LLVMInsertValueInst >> element [
	^ element
]

{ #category : #accessing }
LLVMInsertValueInst >> element: anObject [
	element := anObject
]

{ #category : #accessing }
LLVMInsertValueInst >> indices [
	^ indices
]

{ #category : #accessing }
LLVMInsertValueInst >> indices: anObject [
	indices := anObject
]

{ #category : #printing }
LLVMInsertValueInst >> mnemonic [
	^ #insertvalue
]

{ #category : #printing }
LLVMInsertValueInst >> printParametersOn: aStream [
	aStream space; print: type; space; print: aggregate;
		nextPutAll: ', '; print: element type; space; print: element.
	indices do: [ :elementIndex |
		aStream nextPutAll: ', '; print: elementIndex
	]
]
