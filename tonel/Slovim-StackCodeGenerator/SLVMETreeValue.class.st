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
SLVMETreeValue >> isAlloca [
	^ false
]

{ #category : #testing }
SLVMETreeValue >> isBranch [
	^ false
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

{ #category : #testing }
SLVMETreeValue >> isGetElementPointer [
	^ false
]

{ #category : #testing }
SLVMETreeValue >> isLoad [
	^ false
]

{ #category : #testing }
SLVMETreeValue >> isStore [
	^ false
]

{ #category : #testing }
SLVMETreeValue >> isTerminator [
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
