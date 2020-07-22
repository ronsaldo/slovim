Class {
	#name : #LLVMComdat,
	#superclass : #LLVMObject,
	#instVars : [
		'name',
		'type'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMComdat >> fullPrintOn: aStream [
	self printOn: aStream.
	aStream nextPutAll:  ' = comdat '; nextPutAll: type.
]

{ #category : #accessing }
LLVMComdat >> name [
	^ name
]

{ #category : #accessing }
LLVMComdat >> name: anObject [
	name := anObject
]

{ #category : #printing }
LLVMComdat >> printOn: aStream [
	aStream nextPut: $$.
	name llvmPrintNameOn: aStream
]

{ #category : #accessing }
LLVMComdat >> type [
	^ type
]

{ #category : #accessing }
LLVMComdat >> type: anObject [
	type := anObject
]
