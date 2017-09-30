Class {
	#name : #SLVMETreeReturnExpression,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeReturnExpression >> accept: aVisitor [
	^ aVisitor visitReturn: self
]

{ #category : #testing }
SLVMETreeReturnExpression >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMETreeReturnExpression >> name [
	^ #return
]

{ #category : #evaluating }
SLVMETreeReturnExpression >> value [
	^ parameters first
]
