Class {
	#name : #SLVMFloatType,
	#superclass : #SLVMPrimitiveType,
	#category : #'Slovim-Core-Type'
}

{ #category : #visitor }
SLVMFloatType >> accept: aVisitor [
	^ aVisitor visitFloatType: self
]

{ #category : #testing }
SLVMFloatType >> isFloatType [
	^ true
]
