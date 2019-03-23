"
I represent a high-level code building element. I am used as way to simplify constructing SSA IR, and to facilitate the writing of tests.
"
Class {
	#name : #SLVMHLSequenceExpression,
	#superclass : #SLVMObject,
	#instVars : [
		'block',
		'exitBlock',
		'result'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMHLSequenceExpression >> block [
	^ block
]

{ #category : #accessing }
SLVMHLSequenceExpression >> block: anObject [
	block := anObject
]

{ #category : #accessing }
SLVMHLSequenceExpression >> exitBlock [
	^ exitBlock
]

{ #category : #accessing }
SLVMHLSequenceExpression >> exitBlock: anObject [
	exitBlock := anObject
]

{ #category : #accessing }
SLVMHLSequenceExpression >> result [
	^ result
]

{ #category : #accessing }
SLVMHLSequenceExpression >> result: anObject [
	result := anObject
]
