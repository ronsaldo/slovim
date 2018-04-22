Class {
	#name : #LLVMStructType,
	#superclass : #LLVMCompositeType,
	#instVars : [
		'elements'
	],
	#category : #'LLVM-IR-Types'
}

{ #category : #accessing }
LLVMStructType >> elements [
	^ elements
]

{ #category : #accessing }
LLVMStructType >> elements: anObject [
	elements := anObject
]

{ #category : #printing }
LLVMStructType >> fullPrintOn: aStream [
	aStream print: self; nextPutAll: ' = '.
	self printDefinitionOn: aStream
]

{ #category : #printing }
LLVMStructType >> printDefinitionOn: aStream [
	elements ifNil: [ 
		aStream nextPutAll: 'type opaque'.
		^ self
	].

	aStream nextPutAll: 'type {'.
	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: element
	].
	aStream nextPut: $}
]
