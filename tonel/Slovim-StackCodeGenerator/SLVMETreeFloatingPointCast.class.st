Class {
	#name : #SLVMETreeFloatingPointCast,
	#superclass : #SLVMETreeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeFloatingPointCast >> accept: aVisitor [
	^ aVisitor visitFloatingPointCast: self
]

{ #category : #visiting }
SLVMETreeFloatingPointCast >> name [
	^ #fpcast
]
