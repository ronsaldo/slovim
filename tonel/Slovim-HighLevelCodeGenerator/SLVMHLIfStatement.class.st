Class {
	#name : #SLVMHLIfStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'condition',
		'trueBody',
		'falseBody'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLIfStatement >> condition [
	^ condition
]

{ #category : #accessing }
SLVMHLIfStatement >> condition: anObject [
	condition := anObject
]

{ #category : #accessing }
SLVMHLIfStatement >> falseBody [
	^ falseBody
]

{ #category : #accessing }
SLVMHLIfStatement >> falseBody: anObject [
	falseBody := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLIfStatement >> isIfStatement [
	^ true
]

{ #category : #converting }
SLVMHLIfStatement >> translateWith: translator [
	^ translator translateHLIfStatement: self
]

{ #category : #accessing }
SLVMHLIfStatement >> trueBody [
	^ trueBody
]

{ #category : #accessing }
SLVMHLIfStatement >> trueBody: anObject [
	trueBody := anObject
]
