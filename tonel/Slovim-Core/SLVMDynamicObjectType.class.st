Class {
	#name : #SLVMDynamicObjectType,
	#superclass : #SLVMOpaqueType,
	#category : #'Slovim-Core-Type'
}

{ #category : #comparing }
SLVMDynamicObjectType >> = other [
	^ self class == other class
]

{ #category : #visitor }
SLVMDynamicObjectType >> accept: aVisitor [
	^ aVisitor visitDynamicObjectType: self
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectType >> baseType [
	^ self
]

{ #category : #comparing }
SLVMDynamicObjectType >> hash [
	^ self class hash
]

{ #category : #testing }
SLVMDynamicObjectType >> isDynamicObjectType [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectType >> pointerTypeOfMemberAt: index depth: depth [
	depth = 0 ifTrue: [ ^ self ].
	^ SLVMPointerType baseType: (self typeOfMemberAt: index) storage: SLVMType genericStorage
]

{ #category : #printing }
SLVMDynamicObjectType >> printOn: aStream [
	aStream nextPutAll: 'dynobject'
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectType >> referenceTypeOfMemberAt: index [
	^ SLVMReferenceType baseType: (self typeOfMemberAt: index) storage: SLVMType genericStorage
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectType >> typeOfMemberAt: index [
	^ self
]
