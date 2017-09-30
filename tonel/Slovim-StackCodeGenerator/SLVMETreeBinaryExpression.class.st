Class {
	#name : #SLVMETreeBinaryExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'operation'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeBinaryExpression >> accept: aVisitor [
	^ aVisitor visitBinaryExpression: self
]

{ #category : #accessing }
SLVMETreeBinaryExpression >> left [
	^ parameters first
]

{ #category : #accessing }
SLVMETreeBinaryExpression >> name [
	^ operation
]

{ #category : #accessing }
SLVMETreeBinaryExpression >> operation [
	^ operation
]

{ #category : #accessing }
SLVMETreeBinaryExpression >> operation: anObject [
	operation := anObject
]

{ #category : #accessing }
SLVMETreeBinaryExpression >> right [
	^ parameters second
]
