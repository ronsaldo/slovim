Class {
	#name : #SLVMETreeJumpExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'destination'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeJumpExpression >> accept: aVisitor [
	^ aVisitor visitJump: self
]

{ #category : #accessing }
SLVMETreeJumpExpression >> destination [
	^ destination
]

{ #category : #accessing }
SLVMETreeJumpExpression >> destination: anObject [
	destination := anObject
]

{ #category : #testing }
SLVMETreeJumpExpression >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMETreeJumpExpression >> name [
	^ #jump
]

{ #category : #printing }
SLVMETreeJumpExpression >> prettyPrintOn: aStream [
	aStream nextPutAll: '('; putKeyword: self name.
	aStream space.
	destination prettyPrintOn: aStream.
	aStream nextPutAll: ')'
]
