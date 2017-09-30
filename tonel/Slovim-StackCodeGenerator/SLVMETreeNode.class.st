Class {
	#name : #SLVMETreeNode,
	#superclass : #SLVMETreeObject,
	#instVars : [
		'debugInformation',
		'debugSourceLocation'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeNode >> debugInformation [
	^ debugInformation
]

{ #category : #accessing }
SLVMETreeNode >> debugInformation: anObject [
	debugInformation := anObject
]

{ #category : #accessing }
SLVMETreeNode >> debugSourceLocation [
	^ debugSourceLocation
]

{ #category : #accessing }
SLVMETreeNode >> debugSourceLocation: anObject [
	debugSourceLocation := anObject
]

{ #category : #printing }
SLVMETreeNode >> prettyPrintOn: aStream [
	self printOn: aStream
]
