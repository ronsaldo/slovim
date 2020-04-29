Class {
	#name : #SLVMGetElementPointerCanonicalFragment,
	#superclass : #SLVMObject,
	#instVars : [
		'type',
		'indices'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMGetElementPointerCanonicalFragment >> indices [
	^ indices
]

{ #category : #accessing }
SLVMGetElementPointerCanonicalFragment >> indices: anObject [
	indices := anObject
]

{ #category : #initialization }
SLVMGetElementPointerCanonicalFragment >> initialize [
	super initialize.
	indices := OrderedCollection new.
]

{ #category : #accessing }
SLVMGetElementPointerCanonicalFragment >> type [
	^ type
]

{ #category : #accessing }
SLVMGetElementPointerCanonicalFragment >> type: anObject [
	type := anObject
]
