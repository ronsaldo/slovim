Class {
	#name : #LLVMArgument,
	#superclass : #LLVMValue,
	#instVars : [
		'parent',
		'argNo'
	],
	#category : #'LLVM-IR'
}

{ #category : #accessing }
LLVMArgument >> argNo [
	^ argNo
]

{ #category : #accessing }
LLVMArgument >> argNo: anObject [
	argNo := anObject
]

{ #category : #accessing }
LLVMArgument >> parent [
	^ parent
]

{ #category : #accessing }
LLVMArgument >> parent: anObject [
	parent := anObject
]

{ #category : #printing }
LLVMArgument >> printOnDeclaration: aStream [
	aStream print: type
]

{ #category : #printing }
LLVMArgument >> printOnDefinition: aStream [
	aStream print: type.
	name isLLVMAnon ifFalse: [ 
		aStream nextPutAll: ' %'; nextPutAll: name.
	].

]
