Class {
	#name : #LLVMGetElementPtrInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'pointer',
		'indices'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMGetElementPtrInst >> computeResultType [
	| memberType |
	memberType := pointer type.
	self assert: indices isEmpty not.
	indices do: [ :each |
		memberType := memberType computeMemberTypeFor: each
	].

	type := LLVMPointerType get: memberType addressSpace: pointer type addressSpace
]

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
