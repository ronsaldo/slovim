Class {
	#name : #SLVMETreeAllocaExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'valueType'
	],
	#category : #'Slovim-StackCodeGenerator'
}

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
