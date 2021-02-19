Class {
	#name : #LLVMMDString,
	#superclass : #LLVMMetadata,
	#instVars : [
		'context',
		'value'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMMDString >> buildHandle [
	handle := context validHandle mdString: value slen: value size.
]

{ #category : #accessing }
LLVMMDString >> context [

	^ context
]

{ #category : #accessing }
LLVMMDString >> context: anObject [

	context := anObject
]

{ #category : #printing }
LLVMMDString >> printOn: aStream [
	aStream nextPut: $!.
	value llvmPrintEscapedStringOn: aStream
]

{ #category : #accessing }
LLVMMDString >> value [
	^ value
]

{ #category : #accessing }
LLVMMDString >> value: anObject [
	value := anObject
]
