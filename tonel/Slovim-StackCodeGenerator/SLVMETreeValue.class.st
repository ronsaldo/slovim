Class {
	#name : #SLVMETreeValue,
	#superclass : #SLVMETreeNode,
	#instVars : [
		'type'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #testing }
SLVMETreeValue >> isConstantDynamicLiteral [
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
