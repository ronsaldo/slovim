Class {
	#name : #SLVMETreeAllocaExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'valueType'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeAllocaExpression >> accept: aVisitor [
	^ aVisitor visitAlloca: self
]

{ #category : #testing }
SLVMETreeAllocaExpression >> isAlloca [
	^ true
]

{ #category : #accessing }
SLVMETreeAllocaExpression >> name [
	^ #alloca
]

{ #category : #accessing }
SLVMETreeAllocaExpression >> valueType [
	^ valueType
]

{ #category : #accessing }
SLVMETreeAllocaExpression >> valueType: anObject [
	valueType := anObject
]
