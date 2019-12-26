Class {
	#name : #SLVMDebugDerivedType,
	#superclass : #SLVMDebugType,
	#instVars : [
		'baseType',
		'bitOffset'
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
