Class {
	#name : #SLVMETreeValue,
	#superclass : #SLVMETreeNode,
	#instVars : [
		'type'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeValue >> accept: aVisitor [
	self subclassResponsibility
]

{ #category : #testing }
SLVMETreeValue >> isConstant [
	^ false
]

{ #category : #testing }
SLVMETreeValue >> isConstantDynamicLiteral [
	^ false
]

{ #category : #testing }
SLVMETreeValue >> isConstantValue [
	^ false
]

{ #category : #testing }
SLVMETreeValue >> isFunctionArgument [
	^ false
]

{ #category : #accessing }
SLVMETreeValue >> type [
	^ type
]

{ #category : #accessing }
SLVMETreeValue >> type: anObject [
	type := anObject
]
