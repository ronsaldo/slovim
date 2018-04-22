Class {
	#name : #LLVMArrayType,
	#superclass : #LLVMSequentialType,
	#instVars : [
		'elementType',
		'elements'
	],
	#category : #'LLVM-IR-Types'
}

{ #category : #'as yet unclassified' }
LLVMArrayType class >> get: elementType elements: elements [
	^ elementType context typeAt: { self . elementType . elements }
		ifAbsentPut: [ self new
				context: elementType context;
				elementType: elementType;
				elements: elements;
				yourself ]
]

{ #category : #accessing }
LLVMArrayType >> createName [
	^ ByteString streamContents: [ :out |
		out nextPut: $[; print: elements; nextPutAll: ' x ' ; print: elementType; nextPut: $]
	]
]

{ #category : #accessing }
LLVMArrayType >> elementType [
	^ elementType
]

{ #category : #accessing }
LLVMArrayType >> elementType: anObject [
	elementType := anObject
]

{ #category : #accessing }
LLVMArrayType >> elements [
	^ elements
]

{ #category : #accessing }
LLVMArrayType >> elements: anObject [
	elements := anObject
]

{ #category : #accessing }
LLVMArrayType >> name [
	^ name ifNil: [ name := self createName ]
]
