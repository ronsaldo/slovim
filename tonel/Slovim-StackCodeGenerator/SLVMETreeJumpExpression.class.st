Class {
	#name : #SLVMETreeJumpExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'destination'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeJumpExpression >> destination [
	^ destination
]

{ #category : #accessing }
SLVMETreeJumpExpression >> destination: anObject [
	destination := anObject
]

{ #category : #accessing }
SLVMETreeJumpExpression >> name [
	^ #jump
]
