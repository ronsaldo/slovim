Class {
	#name : #LLVMConstantDataArray,
	#superclass : #LLVMConstantDataSequential,
	#instVars : [
		'elements',
		'addNull'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMConstantDataArray >> addNull [
	^ addNull
]

{ #category : #accessing }
LLVMConstantDataArray >> addNull: anObject [
	addNull := anObject
]

{ #category : #accessing }
LLVMConstantDataArray >> elements [
	^ elements
]

{ #category : #accessing }
LLVMConstantDataArray >> elements: anObject [
	elements := anObject
]

{ #category : #printing }
LLVMConstantDataArray >> printOn: aStream [
	| elementType |		
	elementType := type elementType.
	(elements isString and: [ elementType isIntegerTy and: [ elementType bits = 8 ] ]) ifTrue: [ 
		aStream nextPut: $c.
		elements llvmPrintEscapedStringOn: aStream addNull: addNull.
		^ self
	].

	aStream nextPut: $[.
	aStream nextPut: $].
	self halt
]