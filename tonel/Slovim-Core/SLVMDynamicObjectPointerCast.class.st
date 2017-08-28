Class {
	#name : #SLVMDynamicObjectPointerCast,
	#superclass : #SLVMCast,
	#instVars : [
		'unchecked'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMDynamicObjectPointerCast class >> source: source targetType: targetType typeObject: typeObject [
	^ self new source: source targetType: targetType typeObject: typeObject
]

{ #category : #initialization }
SLVMDynamicObjectPointerCast >> initialize [
	super initialize.
	unchecked := false.
]

{ #category : #testing }
SLVMDynamicObjectPointerCast >> isDynamicObjectReferenceCreator [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectPointerCast >> source: source targetType: targetType [
	self shouldNotImplement
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectPointerCast >> source: source targetType: targetType typeObject: typeObject [
	self parameters: { source . typeObject }.
	type := targetType
	
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectPointerCast >> typeObject [
	^ parameters second
]

{ #category : #accessing }
SLVMDynamicObjectPointerCast >> unchecked [
	^ unchecked
]

{ #category : #accessing }
SLVMDynamicObjectPointerCast >> unchecked: anObject [
	unchecked := anObject
]
