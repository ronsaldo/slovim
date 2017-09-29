Class {
	#name : #SLVMETreeBinaryExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'operation'
	],
	#category : #'Slovim-StackCodeGenerator'
}

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
