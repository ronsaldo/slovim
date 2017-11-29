Class {
	#name : #SLVMETreeUnreachable,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeUnreachable >> accept: aVisitor [
	^ aVisitor visitUnreachable: self
]

{ #category : #accessing }
SLVMETreeUnreachable >> name [
	^ #unreachable
]
