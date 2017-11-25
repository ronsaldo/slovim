Class {
	#name : #SLVMETreeLoadExpression,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeLoadExpression >> accept: aVisitor [
	^ aVisitor visitLoad: self
]

{ #category : #testing }
SLVMETreeLoadExpression >> isLoad [
	^ true
]

{ #category : #testing }
SLVMETreeLoadExpression >> isPureExpression [
	^ self variable isPureExpression
]

{ #category : #accessing }
SLVMETreeLoadExpression >> name [
	^ #load
]

{ #category : #accessing }
SLVMETreeLoadExpression >> variable [
	^ parameters first
]
