Class {
	#name : #SLVMHLLoopStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'body',
		'continueBody'
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

{ #category : #accessing }
SLVMHLLoopStatement >> continueBody [
	^ continueBody
]

{ #category : #accessing }
SLVMHLLoopStatement >> continueBody: anObject [
	continueBody := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLLoopStatement >> removeFinalContinues [
	body removeFinalContinues
]

{ #category : #converting }
SLVMHLLoopStatement >> translateWith: translator [
	^ translator translateHLLoopStatement: self
]
