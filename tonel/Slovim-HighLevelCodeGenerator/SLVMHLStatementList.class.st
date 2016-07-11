Class {
	#name : #SLVMHLStatementList,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'statements'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMHLStatementList >> add: aStatement [
	statements add: aStatement
]

{ #category : #'as yet unclassified' }
SLVMHLStatementList >> initialize [
	super initialize.
	statements := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
SLVMHLStatementList >> isEmpty [
	^ statements isEmpty
]

{ #category : #accessing }
SLVMHLStatementList >> statements [
	^ statements
]

{ #category : #accessing }
SLVMHLStatementList >> statements: anObject [
	statements := anObject
]

{ #category : #converting }
SLVMHLStatementList >> translateInlineWith: translator [
	^ translator translateHLStatementListInline: self
]

{ #category : #converting }
SLVMHLStatementList >> translateWith: translator [
	^ translator translateHLStatementList: self
]
