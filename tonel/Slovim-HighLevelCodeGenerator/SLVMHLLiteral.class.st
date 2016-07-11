Class {
	#name : #SLVMHLLiteral,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'value'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMHLLiteral >> translateValueWith: translator [
	^ translator translateHLLiteralValue: self
]

{ #category : #accessing }
SLVMHLLiteral >> value [
	^ value
]

{ #category : #accessing }
SLVMHLLiteral >> value: anObject [
	value := anObject
]
