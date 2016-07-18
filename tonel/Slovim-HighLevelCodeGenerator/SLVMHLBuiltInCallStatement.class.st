Class {
	#name : #SLVMHLBuiltInCallStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'function',
		'arguments'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLBuiltInCallStatement >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMHLBuiltInCallStatement >> arguments: anObject [
	arguments := anObject.
	arguments do: [ :arg | self assert: arg isCodeNode]
]

{ #category : #accessing }
SLVMHLBuiltInCallStatement >> function [
	^ function
]

{ #category : #accessing }
SLVMHLBuiltInCallStatement >> function: anObject [
	function := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLBuiltInCallStatement >> translateValueWith: translator [
	^ translator translateHLBuiltInCallStatementValue: self
]
