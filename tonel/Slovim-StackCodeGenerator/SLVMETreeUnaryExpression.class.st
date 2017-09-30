Class {
	#name : #SLVMETreeUnaryExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'operation'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeUnaryExpression >> accept: aVisitor [
	^ aVisitor visitUnaryExpression: self
]

{ #category : #accessing }
SLVMETreeUnaryExpression >> name [
	^ operation
]

{ #category : #accessing }
SLVMETreeUnaryExpression >> operand [
	^ parameters first
]

{ #category : #accessing }
SLVMETreeUnaryExpression >> operation [
	^ operation
]

{ #category : #accessing }
SLVMETreeUnaryExpression >> operation: anObject [
	operation := anObject
]
