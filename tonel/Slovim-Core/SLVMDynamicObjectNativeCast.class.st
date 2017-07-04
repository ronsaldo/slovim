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

{ #category : #accessing }
SLVMDynamicObjectNativeCast >> unchecked [
	^ unchecked
]

{ #category : #accessing }
SLVMDynamicObjectNativeCast >> unchecked: anObject [
	unchecked := anObject
]
