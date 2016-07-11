Class {
	#name : #SLVMHLUntilLoopStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'condition',
		'body'
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

{ #category : #'as yet unclassified' }
SLVMHLUntilLoopStatement >> translateWith: translator [
	^ translator translateHLUntilLoopStatement: self
]
