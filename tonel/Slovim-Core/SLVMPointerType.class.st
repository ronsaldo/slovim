Class {
	#name : #SLVMPointerType,
	#superclass : #SLVMType,
	#instVars : [
		'size',
		'baseType',
		'storage'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMPointerType class >> size: size baseType: aBaseType storage: storage [
	^ self new size: size; baseType: aBaseType; storage: storage; yourself
]

{ #category : #comparing }
SLVMPointerType >> = other [
	^ self class == other class and: [ baseType = other baseType and: [ storage = other storage ] ] 
]

{ #category : #visitor }
SLVMPointerType >> accept: aVisitor [
	^ aVisitor visitPointerType: self
]

{ #category : #accessing }
SLVMPointerType >> alignment [
	^ size
]

{ #category : #accessing }
SLVMPointerType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMPointerType >> baseType: aType [
	self assert: aType isSlovimType.
	baseType := aType
]

{ #category : #comparing }
SLVMPointerType >> hash [
	^ (self class hash bitXor: baseType hash) bitXor: storage hash
]

{ #category : #testing }
SLVMPointerType >> isPointerType [
	^ true
]

{ #category : #testing }
SLVMPointerType >> isScalarType [
	^ true
]

{ #category : #accessing }
SLVMPointerType >> pointerSize: pointerSize typeOfMemberAt: index depth: depth [
	depth = 0 ifTrue: [ ^ self ].
	^ SLVMPointerType size: pointerSize baseType: (self typeOfMemberAt: index) storage: storage
]

{ #category : #printing }
SLVMPointerType >> printOn: aStream [
	aStream print: baseType;
		nextPutAll: ' ref '; print: storage
]

{ #category : #accessing }
SLVMPointerType >> size [
	^ size
]

{ #category : #accessing }
SLVMPointerType >> size: anObject [
	size := anObject
]

{ #category : #accessing }
SLVMPointerType >> storage [
	^ storage
]

{ #category : #accessing }
SLVMPointerType >> storage: aSymbol [
	self assert: aSymbol isSymbol.
	storage := aSymbol
]

{ #category : #accessing }
SLVMPointerType >> typeOfMemberAt: index [
	^ baseType memberAt: index
]
