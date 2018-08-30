Class {
	#name : #SLVMETreeInsertValue,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'indices'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeInsertValue >> accept: aVisitor [
	^ aVisitor visitInsertValue: self
]

{ #category : #accessing }
SLVMETreeInsertValue >> aggregate [
	^ parameters first
]

{ #category : #testing }
SLVMETreeInsertValue >> canOmitCopy [
	^ self aggregate isInsertValue
]

{ #category : #accessing }
SLVMETreeInsertValue >> indices [
	^ indices
]

{ #category : #accessing }
SLVMETreeInsertValue >> indices: anObject [
	indices := anObject
]

{ #category : #testing }
SLVMETreeInsertValue >> isInsertValue [
	^ true
]

{ #category : #accessing }
SLVMETreeInsertValue >> name [
	^ #insertvalue
]

{ #category : #accessing }
SLVMETreeInsertValue >> value [
	^ parameters second
]
