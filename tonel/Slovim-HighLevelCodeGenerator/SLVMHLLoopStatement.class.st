Class {
	#name : #SLVMHLLoopStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'body'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLLoopStatement >> body [
	^ body
]

{ #category : #accessing }
SLVMHLLoopStatement >> body: anObject [
	body := anObject
]

{ #category : #converting }
SLVMHLLoopStatement >> translateWith: translator [
	^ translator translateHLLoopStatement: self
]
