Class {
	#name : #SLVMETreeUndefined,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeUndefined >> accept: aVisitor [
	^ aVisitor visitUndefinedInstruction: self
]

{ #category : #accessing }
SLVMETreeUndefined >> name [
	^ #undefined
]
