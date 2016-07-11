Class {
	#name : #SLVMHLLoadStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'variable'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #converting }
SLVMHLLoadStatement >> translateValueWith: translator [
	^ translator translateHLLoadStatementValue: self
]

{ #category : #converting }
SLVMHLLoadStatement >> translateWith: translator [
	^ translator translateHLLoadStatement: self
]

{ #category : #accessing }
SLVMHLLoadStatement >> variable [
	^ variable
]

{ #category : #accessing }
SLVMHLLoadStatement >> variable: anObject [
	variable := anObject
]
