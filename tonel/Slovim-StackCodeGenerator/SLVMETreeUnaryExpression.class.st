Class {
	#name : #SLVMETreeUnaryExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'operation'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeUnaryExpression >> name [
	^ operation
]

{ #category : #accessing }
SLVMETreeUnaryExpression >> operation [
	^ operation
]

{ #category : #accessing }
SLVMETreeUnaryExpression >> operation: anObject [
	operation := anObject
]
