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
	^ 1
]

{ #category : #converting }
SLVMOpaqueType >> asFullSExpression [
	self assert: name isNotNil.
	^ name
]

{ #category : #comparing }
SLVMOpaqueType >> internalHash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	May be overridden, and should be overridden in any classes that define = "

	^ self identityHash 
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
