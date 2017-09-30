Class {
	#name : #SLVMETreeReturnVoidExpression,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeReturnVoidExpression >> accept: aVisitor [
	^ aVisitor visitReturnVoid: self
]

{ #category : #testing }
SLVMETreeReturnVoidExpression >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMETreeReturnVoidExpression >> name [
	^ #returnVoid
]
