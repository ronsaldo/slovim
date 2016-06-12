Class {
	#name : #SLVMOpaqueType,
	#superclass : #SLVMType,
	#instVars : [
		'name'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVMOpaqueType >> alignment [
	^ 0
]

{ #category : #testing }
SLVMOpaqueType >> isOpaqueType [
	^ true
]

{ #category : #accessing }
SLVMOpaqueType >> name [
	^ name
]

{ #category : #accessing }
SLVMOpaqueType >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMOpaqueType >> size [
	^ 0
]
