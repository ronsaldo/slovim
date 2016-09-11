Class {
	#name : #SLVMConstantDynamicLiteral,
	#superclass : #SLVMConstant,
	#instVars : [
		'index',
		'value',
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMConstantDynamicLiteral >> accept: aVisitor [
	^ aVisitor visitConstantDynamicLiteral: self
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> index [
	^ index
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> index: anObject [
	index := anObject
]

{ #category : #'as yet unclassified' }
SLVMConstantDynamicLiteral >> isConstantDynamicLiteral [
	^ true
]

{ #category : #printing }
SLVMConstantDynamicLiteral >> printOn: aStream [
	aStream nextPutAll: 'literal '; print: index; nextPutAll: ' '; print: value
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> type: aType [
	type := aType
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> value [
	^ value
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> value: anObject [
	value := anObject
]
