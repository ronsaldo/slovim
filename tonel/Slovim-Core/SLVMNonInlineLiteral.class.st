Class {
	#name : #SLVMNonInlineLiteral,
	#superclass : #SLVMObject,
	#instVars : [
		'literalValue',
		'index',
		'codeGenerationValue'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMNonInlineLiteral >> codeGenerationValue [
	^ codeGenerationValue
]

{ #category : #accessing }
SLVMNonInlineLiteral >> codeGenerationValue: anObject [
	codeGenerationValue := anObject
]

{ #category : #accessing }
SLVMNonInlineLiteral >> index [
	^ index
]

{ #category : #accessing }
SLVMNonInlineLiteral >> index: anObject [
	index := anObject
]

{ #category : #accessing }
SLVMNonInlineLiteral >> literalValue [
	^ literalValue
]

{ #category : #accessing }
SLVMNonInlineLiteral >> literalValue: anObject [
	literalValue := anObject
]

{ #category : #printing }
SLVMNonInlineLiteral >> printOn: aStream [
	aStream nextPutAll: 'Literal '; print: index; nextPutAll: ' :'; print: literalValue
]
