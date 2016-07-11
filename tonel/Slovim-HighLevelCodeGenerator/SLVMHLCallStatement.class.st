Class {
	#name : #SLVMHLCallStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'function',
		'arguments'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLCallStatement >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMHLCallStatement >> arguments: anObject [
	arguments := anObject
]

{ #category : #accessing }
SLVMHLCallStatement >> function [
	^ function
]

{ #category : #accessing }
SLVMHLCallStatement >> function: anObject [
	function := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLCallStatement >> translateValueWith: translator [
	^ translator translateHLCallStatementValue: self
]
