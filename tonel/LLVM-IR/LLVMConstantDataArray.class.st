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
LLVMConstantDataArray >> buildHandle [
	| elementType elementConstants |		
	elementType := type elementType.
	((elements isString or: [ elements class == ByteArray ]) and: [ elementType isIntegerTy and: [ elementType bits = 8 ] ]) ifTrue: [ 
		| blob |
		blob := elements isString ifTrue: [ elements utf8Encoded ] ifFalse: [ elements ].
		handle := type context validHandle constString: blob length: blob size dontNullTerminate: addNull not.
		self assert: (blob size + addNull asBit) = type elements.
		^ self
	].

	elementConstants := elements collect: [ :each | elementType constant: each ].
	addNull ifTrue: [ elementConstants := elementConstants , { elementType zeroConstant } ].
	self assert: elementConstants size = type elements.
	handle := elementType validHandle constArray: (LLVMValueRefArray withAll: elementConstants) getHandle count: elementConstants size.
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

	addNull ifTrue: [
		elements ifNotEmpty: [ aStream nextPutAll: ', ' ].
		elementType printOn: aStream.
		aStream nextPutAll: ' 0'
	].
	aStream nextPutAll: ' ]'.
]
