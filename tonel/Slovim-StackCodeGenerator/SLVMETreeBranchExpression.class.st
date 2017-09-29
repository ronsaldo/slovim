Class {
	#name : #SLVMETreeBranchExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'trueBlock',
		'falseBlock'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeBranchExpression >> falseBlock [
	^ falseBlock
]

{ #category : #accessing }
SLVMETreeBranchExpression >> falseBlock: anObject [
	falseBlock := anObject
]

{ #category : #accessing }
SLVMETreeBranchExpression >> name [
	^ #branch
]

{ #category : #accessing }
SLVMETreeBranchExpression >> trueBlock [
	^ trueBlock
]

{ #category : #accessing }
SLVMETreeBranchExpression >> trueBlock: anObject [
	trueBlock := anObject
]
