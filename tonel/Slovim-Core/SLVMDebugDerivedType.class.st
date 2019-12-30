Class {
	#name : #SLVMDebugDerivedType,
	#superclass : #SLVMDebugType,
	#instVars : [
		'baseType',
		'bitOffset',
		'isBitField'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugDerivedType >> accept: visitor [
	^ visitor visitDebugDerivedType: self
]

{ #category : #accessing }
SLVMDebugDerivedType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMDebugDerivedType >> baseType: anObject [
	baseType := anObject
]

{ #category : #accessing }
SLVMDebugDerivedType >> bitOffset [
	^ bitOffset
]

{ #category : #accessing }
SLVMDebugDerivedType >> bitOffset: anObject [
	bitOffset := anObject
]

{ #category : #accessing }
SLVMDebugDerivedType >> byteOffset: anOffset [
	bitOffset := anOffset * 8
]

{ #category : #accessing }
SLVMDebugDerivedType >> isBitField [
	^ isBitField ifNil: [ isBitField := false ]
]

{ #category : #accessing }
SLVMDebugDerivedType >> isBitField: aBoolean [
	isBitField := aBoolean
]

{ #category : #testing }
SLVMDebugDerivedType >> isDebugDerivedType [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMDebugDerivedType >> makeInheritance [
	kind := #inheritance
]

{ #category : #'as yet unclassified' }
SLVMDebugDerivedType >> makeMember [
	kind := #member
]

{ #category : #'as yet unclassified' }
SLVMDebugDerivedType >> makePointer [
	kind := #pointer
]

{ #category : #'as yet unclassified' }
SLVMDebugDerivedType >> makeReference [
	kind := #reference
]

{ #category : #'as yet unclassified' }
SLVMDebugDerivedType >> makeTemporaryReference [
	kind := #temporaryReference
]
