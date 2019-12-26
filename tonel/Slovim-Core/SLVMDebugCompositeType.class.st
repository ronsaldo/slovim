Class {
	#name : #SLVMDebugCompositeType,
	#superclass : #SLVMDebugType,
	#instVars : [
		'baseType',
		'arrayRange',
		'members'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugCompositeType >> accept: visitor [
	^ visitor visitDebugCompositeType: self
]

{ #category : #accessing }
SLVMDebugCompositeType >> arrayRange [
	^ arrayRange
]

{ #category : #accessing }
SLVMDebugCompositeType >> arrayRange: anObject [
	arrayRange := anObject
]

{ #category : #accessing }
SLVMDebugCompositeType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMDebugCompositeType >> baseType: anObject [
	baseType := anObject
]

{ #category : #initialization }
SLVMDebugCompositeType >> initialize [
	super initialize.
	members := #()
]

{ #category : #'as yet unclassified' }
SLVMDebugCompositeType >> makeArray [
	kind := #array
]

{ #category : #'as yet unclassified' }
SLVMDebugCompositeType >> makeClass [
	kind := #class
]

{ #category : #'as yet unclassified' }
SLVMDebugCompositeType >> makeEnumeration [
	kind := #enumeration
]

{ #category : #'as yet unclassified' }
SLVMDebugCompositeType >> makeStructure [
	kind := #structure
]

{ #category : #'as yet unclassified' }
SLVMDebugCompositeType >> makeUnion [
	kind := #union
]

{ #category : #accessing }
SLVMDebugCompositeType >> members [
	^ members
]

{ #category : #accessing }
SLVMDebugCompositeType >> members: anObject [
	members := anObject
]
