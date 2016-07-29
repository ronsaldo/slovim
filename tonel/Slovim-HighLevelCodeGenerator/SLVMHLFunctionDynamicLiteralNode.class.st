Class {
	#name : #SLVMHLFunctionDynamicLiteralNode,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'index',
		'value'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLFunctionDynamicLiteralNode >> index [
	^ index
]

{ #category : #accessing }
SLVMHLFunctionDynamicLiteralNode >> index: anObject [
	index := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLFunctionDynamicLiteralNode >> translateValueWith: translator [
	^ translator translateHLFunctionDynamicLiteralNodeValue: self
]

{ #category : #accessing }
SLVMHLFunctionDynamicLiteralNode >> value [
	^ value
]

{ #category : #accessing }
SLVMHLFunctionDynamicLiteralNode >> value: anObject [
	value := anObject
]
