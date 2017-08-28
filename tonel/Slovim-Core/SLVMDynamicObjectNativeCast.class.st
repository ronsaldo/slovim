Class {
	#name : #SLVMDynamicObjectNativeCast,
	#superclass : #SLVMCast,
	#instVars : [
		'unchecked'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #initialization }
SLVMDynamicObjectNativeCast >> initialize [
	super initialize.
	unchecked := false
]

{ #category : #testing }
SLVMDynamicObjectNativeCast >> isDynamicObjectNativeCast [
	^ true
]

{ #category : #testing }
SLVMDynamicObjectNativeCast >> isDynamicObjectReferenceCreator [
	^ true
]

{ #category : #accessing }
SLVMDynamicObjectNativeCast >> unchecked [
	^ unchecked
]

{ #category : #accessing }
SLVMDynamicObjectNativeCast >> unchecked: anObject [
	unchecked := anObject
]
