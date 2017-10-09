Class {
	#name : #SLVMPrimitiveType,
	#superclass : #SLVMType,
	#instVars : [
		'name',
		'size',
		'alignment'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'instance creation' }
SLVMPrimitiveType class >> name: aName size: aSize alignment: anAlignment [
	^ self new name: aName; size: aSize; alignment: anAlignment; yourself
]

{ #category : #comparing }
SLVMPrimitiveType >> = other [
	^ self class == other class and: [ size = other size and: [ alignment = other alignment ] ]
]

{ #category : #accessing }
SLVMPrimitiveType >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMPrimitiveType >> alignment: anObject [
	alignment := anObject
]

{ #category : #comparing }
SLVMPrimitiveType >> internalHash [
	^ (self class hash bitXor: size hash) bitXor: alignment hash
]

{ #category : #testing }
SLVMPrimitiveType >> isPrimitiveType [
	^ true
]

{ #category : #testing }
SLVMPrimitiveType >> isScalarType [
	^ true
]

{ #category : #accessing }
SLVMPrimitiveType >> name [
	^ name
]

{ #category : #accessing }
SLVMPrimitiveType >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMPrimitiveType >> printOn: aStream [
	aStream nextPutAll: name
]

{ #category : #'as yet unclassified' }
SLVMPrimitiveType >> selectorForStoringIntoPointer [
	^ (self selectorForLoadingFromPointer , ':') asSymbol
]

{ #category : #accessing }
SLVMPrimitiveType >> size [
	^ size
]

{ #category : #accessing }
SLVMPrimitiveType >> size: anObject [
	size := anObject
]
