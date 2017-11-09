Class {
	#name : #SLVMETreeBranchExpression,
	#superclass : #SLVMETreeExpression,
	#instVars : [
		'trueBlock',
		'falseBlock'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeBranchExpression >> accept: aVisitor [
	^ aVisitor visitBranch: self
]

{ #category : #accessing }
SLVMETreeBranchExpression >> condition [
	^ parameters first
]

{ #category : #accessing }
SLVMETreeBranchExpression >> falseBlock [
	^ falseBlock
]

{ #category : #accessing }
SLVMETreeBranchExpression >> falseBlock: anObject [
	falseBlock := anObject
]

{ #category : #testing }
SLVMETreeBranchExpression >> isBranch [
	^ true
]

{ #category : #testing }
SLVMETreeBranchExpression >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMETreeBranchExpression >> name [
	^ #branch
]

{ #category : #printing }
SLVMETreeBranchExpression >> prettyPrintOn: aStream [
	aStream nextPutAll: '('; putKeyword: self name.
	aStream space.
	self condition prettyPrintOn: aStream.
	aStream space.
	trueBlock prettyPrintOn: aStream.
	aStream space.
	falseBlock prettyPrintOn: aStream.
	aStream nextPutAll: ')'
]

{ #category : #accessing }
SLVMETreeBranchExpression >> trueBlock [
	^ trueBlock
]

{ #category : #accessing }
SLVMETreeBranchExpression >> trueBlock: anObject [
	trueBlock := anObject
]
