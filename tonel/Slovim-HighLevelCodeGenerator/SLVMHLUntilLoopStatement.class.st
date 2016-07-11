Class {
	#name : #SLVMHLUntilLoopStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'condition',
		'body',
		'continueBody'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLUntilLoopStatement >> body [
	^ body
]

{ #category : #accessing }
SLVMHLUntilLoopStatement >> body: anObject [
	body := anObject
]

{ #category : #accessing }
SLVMHLUntilLoopStatement >> condition [
	^ condition
]

{ #category : #accessing }
SLVMHLUntilLoopStatement >> condition: anObject [
	condition := anObject
]

{ #category : #accessing }
SLVMHLUntilLoopStatement >> continueBody [
	^ continueBody
]

{ #category : #accessing }
SLVMHLUntilLoopStatement >> continueBody: anObject [
	continueBody := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLUntilLoopStatement >> translateWith: translator [
	^ translator translateHLUntilLoopStatement: self
]
