Class {
	#name : #SLVMBoolType,
	#superclass : #SLVMPrimitiveType,
	#category : #'Slovim-Core-Type'
}

{ #category : #visitor }
SLVMBoolType >> accept: aVisitor [
	^ aVisitor visitBoolType: self
]

{ #category : #initialization }
SLVMBoolType >> initialize [
	super initialize.
	self name: #bool;
		size: 4.
]

{ #category : #testing }
SLVMBoolType >> isBooleanType [
	^ true
]
