Class {
	#name : #SLVMHLWhileLoopStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'condition',
		'body',
		'continueBody'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLWhileLoopStatement >> body [
	^ body
]

{ #category : #accessing }
SLVMHLWhileLoopStatement >> body: anObject [
	body := anObject
]

{ #category : #accessing }
SLVMHLWhileLoopStatement >> condition [
	^ condition
]

{ #category : #accessing }
SLVMHLWhileLoopStatement >> condition: anObject [
	condition := anObject
]

{ #category : #accessing }
SLVMHLWhileLoopStatement >> continueBody [
	^ continueBody
]

{ #category : #accessing }
SLVMHLWhileLoopStatement >> continueBody: anObject [
	continueBody := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLWhileLoopStatement >> removeFinalContinues [
	body removeFinalContinues
]

{ #category : #'as yet unclassified' }
SLVMHLWhileLoopStatement >> translateWith: translator [
	^ translator translateHLWhileLoopStatement: self
]
