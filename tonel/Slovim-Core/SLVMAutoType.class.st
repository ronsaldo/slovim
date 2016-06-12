Class {
	#name : #SLVMAutoType,
	#superclass : #SLVMOpaqueType,
	#category : #'Slovim-Core-Type'
}

{ #category : #comparing }
SLVMAutoType >> = other [
	^ self class == other class
]

{ #category : #visitor }
SLVMAutoType >> accept: aVisitor [
	^ aVisitor visitAutoType: self
]

{ #category : #comparing }
SLVMAutoType >> hash [
	^ self class hash
]

{ #category : #testing }
SLVMAutoType >> isAutoType [
	^ true
]
