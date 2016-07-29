Class {
	#name : #SLVMConstantDynamicLiteral,
	#superclass : #SLVMConstant,
	#instVars : [
		'index',
		'value'
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

{ #category : #printing }
SLVMConstantDynamicLiteral >> printOn: aStream [
	aStream nextPutAll: 'literal '; print: index; nextPutAll: ' '; print: value
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> type [
	^ SLVMType dynamicObjectType
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> value [
	^ value
]

{ #category : #accessing }
SLVMConstantDynamicLiteral >> value: anObject [
	value := anObject
]
