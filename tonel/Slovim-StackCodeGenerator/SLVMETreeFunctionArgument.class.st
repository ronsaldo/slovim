Class {
	#name : #SLVMETreeFunctionArgument,
	#superclass : #SLVMETreeNode,
	#instVars : [
		'argument'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeFunctionArgument >> argument [
	^ argument
]

{ #category : #accessing }
SLVMETreeFunctionArgument >> argument: anObject [
	argument := anObject
]

{ #category : #printing }
SLVMETreeFunctionArgument >> prettyPrintOn: aStream [
	aStream nextPutAll: '('; putKeyword: #arg; space; putIdentifier: argument name; nextPutAll: ')'
]
