Class {
	#name : #SLVMETreeExtractValue,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'indices'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeExtractValue >> accept: aVisitor [
	^ aVisitor visitExtractValue: self
]

{ #category : #accessing }
SLVMETreeExtractValue >> aggregate [
	^ parameters first
]

{ #category : #accessing }
SLVMETreeExtractValue >> indices [
	^ indices
]

{ #category : #accessing }
SLVMETreeExtractValue >> indices: anObject [
	indices := anObject
]

{ #category : #accessing }
SLVMETreeExtractValue >> name [
	^ #extractvalue
]
