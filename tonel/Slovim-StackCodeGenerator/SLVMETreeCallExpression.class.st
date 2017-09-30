Class {
	#name : #SLVMETreeCallExpression,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeCallExpression >> accept: aVisitor [
	^ aVisitor visitCall: self
]

{ #category : #accessing }
SLVMETreeCallExpression >> arguments [
	^ parameters allButFirst
]

{ #category : #accessing }
SLVMETreeCallExpression >> functionValue [
	^ parameters first
]

{ #category : #accessing }
SLVMETreeCallExpression >> name [
	^ #call
]
