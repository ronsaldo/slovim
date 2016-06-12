Class {
	#name : #SLVMArrayType,
	#superclass : #SLVMType,
	#instVars : [
		'baseType',
		'elements'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMArrayType class >> baseType: baseType elements: elements [
	^ self new baseType: baseType; elements: elements; yourself
]

{ #category : #comparing }
SLVMArrayType >> = other [
	^ self class = other class and: [ baseType = other baseType and: [ elements = other elements ] ]
]

{ #category : #visitor }
SLVMArrayType >> accept: aVisitor [
	^ aVisitor visitArrayType: self
]

{ #category : #accessing }
SLVMArrayType >> alignment [
	^ baseType alignment
]

{ #category : #accessing }
SLVMArrayType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMArrayType >> baseType: anObject [
	baseType := anObject
]

{ #category : #accessing }
SLVMArrayType >> elements [
	^ elements
]

{ #category : #accessing }
SLVMArrayType >> elements: anObject [
	elements := anObject
]

{ #category : #comparing }
SLVMArrayType >> hash [
	^ (self class hash bitXor: baseType hash) bitXor: elements hash
]

{ #category : #testing }
SLVMArrayType >> isArrayType [
	^ true
]

{ #category : #testing }
SLVMArrayType >> isBounded [
	^ elements isNotNil
]

{ #category : #accessing }
SLVMArrayType >> memberAt: constantValue [
	^ baseType
]

{ #category : #printing }
SLVMArrayType >> printOn: aStream [
	aStream print: baseType; nextPut: $[.
	elements ifNotNil: [ aStream print: elements ].
	aStream nextPut: $]
]

{ #category : #accessing }
SLVMArrayType >> size [
	^ self isBounded ifTrue: [ baseType size * elements ] ifFalse: [ 0 ]
]
