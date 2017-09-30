Class {
	#name : #SLVMETreeCast,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeCast >> source [
	^ parameters first
]
