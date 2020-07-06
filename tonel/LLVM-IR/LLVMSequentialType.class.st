Class {
	#name : #LLVMSequentialType,
	#superclass : #LLVMCompositeType,
	#instVars : [
		'elementType',
		'elements'
	],
	#category : #'LLVM-IR-Types'
}

{ #category : #'as yet unclassified' }
LLVMSequentialType class >> get: elementType elements: elements [
	^ elementType context typeAt: { self . elementType . elements }
		ifAbsentPut: [ self new
				context: elementType context;
				elementType: elementType;
				elements: elements;
				yourself ]
]

{ #category : #comparing }
LLVMSequentialType >> = other [
	^ self class == other class and: [ elementType = other elementType and: [ elements = other elements ] ]
]

{ #category : #'as yet unclassified' }
LLVMSequentialType >> computeMemberTypeFor: elementIndex [
	^ elementType
]

{ #category : #accessing }
LLVMSequentialType >> elementType [
	^ elementType
]

{ #category : #accessing }
LLVMSequentialType >> elementType: anObject [
	elementType := anObject
]

{ #category : #accessing }
LLVMSequentialType >> elements [
	^ elements
]

{ #category : #accessing }
LLVMSequentialType >> elements: anObject [
	elements := anObject
]

{ #category : #comparing }
LLVMSequentialType >> hash [
	^ (self class identityHash bitXor: elementType hash) bitXor: elements hash
]

{ #category : #accessing }
LLVMSequentialType >> name [
	^ name ifNil: [ name := self createName ]
]
