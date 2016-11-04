Class {
	#name : #SLVMDynamicObjectType,
	#superclass : #SLVMOpaqueType,
	#instVars : [
		'size'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #comparing }
SLVMDynamicObjectType >> = other [
	^ self class == other class and: [ size == other size ]
]

{ #category : #visitor }
SLVMDynamicObjectType >> accept: aVisitor [
	^ aVisitor visitDynamicObjectType: self
]

{ #category : #accessing }
SLVMDynamicObjectType >> alignment [
	^ size
]

{ #category : #accessing }
SLVMDynamicObjectType >> baseType [
	^ self
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectType >> elementStrideDepth: depth [
	^ size
]

{ #category : #comparing }
SLVMDynamicObjectType >> hash [
	^ self class hash bitXor: size hash
]

{ #category : #initialization }
SLVMDynamicObjectType >> initialize [
	super initialize.
	name := #dynobject.
]

{ #category : #testing }
SLVMDynamicObjectType >> isDynamicObjectType [
	^ true
]

{ #category : #testing }
SLVMDynamicObjectType >> isScalarType [
	^ true
]

{ #category : #accessing }
SLVMDynamicObjectType >> pointerSize: pointerSize typeOfMemberAt: index depth: depth [
	depth = 0 ifTrue: [ ^ self ].
	^ SLVMPointerType size: pointerSize baseType: (self typeOfMemberAt: index) storage: SLVMType genericStorage
]

{ #category : #printing }
SLVMDynamicObjectType >> printOn: aStream [
	aStream nextPutAll: 'dynobject'
]

{ #category : #accessing }
SLVMDynamicObjectType >> size [
	^ size
]

{ #category : #accessing }
SLVMDynamicObjectType >> size: anObject [
	size := anObject
]

{ #category : #accessing }
SLVMDynamicObjectType >> spillingClass [
	^ { self size . self alignment . true }
]

{ #category : #accessing }
SLVMDynamicObjectType >> typeOfMemberAt: index [
	^ self
]
