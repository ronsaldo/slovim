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
	((elements isString or: [ elements class == ByteArray ]) and: [ elementType isIntegerTy and: [ elementType bits = 8 ] ]) ifTrue: [ 
		aStream nextPut: $c.
		elements llvmPrintEscapedStringOn: aStream addNull: addNull.
		^ self
	].

	aStream nextPutAll: '[ '.
	elements doWithIndex: [ :el :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		elementType printOn: aStream.
		aStream space; print: el
	].
	aStream nextPutAll: ' ]'.
]
