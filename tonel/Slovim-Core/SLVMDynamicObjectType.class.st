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

{ #category : #initialization }
SLVMDynamicObjectType >> initialize [
	super initialize.
	name := #dynobject.
]

{ #category : #comparing }
SLVMDynamicObjectType >> internalHash [
	^ self class hash bitXor: size hash
]

{ #category : #testing }
SLVMDynamicObjectType >> isDynamicObjectPointerType [
	^ true
]

{ #category : #testing }
SLVMDynamicObjectType >> isDynamicObjectType [
	^ true
]

{ #category : #testing }
SLVMDynamicObjectType >> isScalarType [
	^ true
]

{ #category : #'element accessing' }
SLVMDynamicObjectType >> offsetWithIndex: index [
	^ index isConstantValue ifTrue: [ self size * index value ] ifFalse: [ 0 ]
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
SLVMDynamicObjectType >> storage [
	^ SLVMType genericStorage
]

{ #category : #'element accessing' }
SLVMDynamicObjectType >> strideWithIndex: index [
	^ index isConstantValue ifTrue: [ 0 ] ifFalse: [ self size ]
]

{ #category : #accessing }
SLVMDynamicObjectType >> typeOfMemberAt: index [
	^ self
]
