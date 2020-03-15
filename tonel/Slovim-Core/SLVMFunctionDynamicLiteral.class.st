Class {
	#name : #SLVMFunctionDynamicLiteral,
	#superclass : #SLVMFunctionLocalValue,
	#instVars : [
		'index',
		'value',
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMFunctionDynamicLiteral class >> mnemonics [
	^ #()
]

{ #category : #visitor }
SLVMFunctionDynamicLiteral >> accept: aVisitor [
	^ aVisitor visitFunctionDynamicLiteral: self
]

{ #category : #printing }
SLVMFunctionDynamicLiteral >> asFullSExpression [
	^ {type asSExpression . value slvmEncodeAsSExpression}
]

{ #category : #accessing }
SLVMFunctionDynamicLiteral >> index [
	^ index
]

{ #category : #accessing }
SLVMFunctionDynamicLiteral >> index: anObject [
	index := anObject
]

{ #category : #'as yet unclassified' }
SLVMFunctionDynamicLiteral >> isFunctionDynamicLiteral [
	^ true
]

{ #category : #printing }
SLVMFunctionDynamicLiteral >> printOn: aStream [
	aStream nextPutAll: 'literal '; print: index; nextPutAll: ' '; print: value
]

{ #category : #accessing }
SLVMFunctionDynamicLiteral >> type [
	^ type
]

{ #category : #accessing }
SLVMFunctionDynamicLiteral >> type: aType [
	type := aType
]

{ #category : #accessing }
SLVMFunctionDynamicLiteral >> value [
	^ value
]

{ #category : #accessing }
SLVMFunctionDynamicLiteral >> value: anObject [
	value := anObject
]
