Class {
	#name : #LLVMInstruction,
	#superclass : #LLVMUser,
	#instVars : [
		'parent'
	],
	#category : #'LLVM-IR'
}

{ #category : #printing }
LLVMInstruction >> fullPrintOn: aStream [
	type isVoidTy ifFalse: [
		aStream print: self.
		aStream << ' = '.
	].
	aStream nextPutAll: self mnemonic.
	self printParametersOn: aStream
]

{ #category : #printing }
LLVMInstruction >> mnemonic [
	self subclassResponsibility
]

{ #category : #accessing }
LLVMInstruction >> parent [
	^ parent
]

{ #category : #accessing }
LLVMInstruction >> parent: anObject [
	parent := anObject
]

{ #category : #printing }
LLVMInstruction >> printParametersOn: aStream [
	self subclassResponsibility
	
]
