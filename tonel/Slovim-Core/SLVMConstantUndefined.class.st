Class {
	#name : #SLVMConstantUndefined,
	#superclass : #SLVMConstant,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantUndefined class >> mnemonic [
	^ #undef
]

{ #category : #'as yet unclassified' }
SLVMConstantUndefined class >> type: aType [
	^ self new type: aType
]

{ #category : #visitor }
SLVMConstantUndefined >> accept: aVisitor [
	^ aVisitor visitConstantUndefined: self
]

{ #category : #printing }
SLVMConstantUndefined >> asSExpression [
	^ { self mnemonic . type asSExpression }
]

{ #category : #testing }
SLVMConstantUndefined >> isUndefined [
	^ true
]

{ #category : #printing }
SLVMConstantUndefined >> printOn: aStream [
	aStream nextPutAll: 'constUndef '; print: type
]

{ #category : #accessing }
SLVMConstantUndefined >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantUndefined >> type: anObject [
	type := anObject
]
