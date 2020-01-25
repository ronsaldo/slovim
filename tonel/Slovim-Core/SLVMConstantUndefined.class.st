Class {
	#name : #SLVMConstantUndefined,
	#superclass : #SLVMConstant,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMConstantUndefined class >> type: aType [
	^ self new type: aType
]

{ #category : #visitor }
SLVMConstantUndefined >> accept: aVisitor [
	^ aVisitor visitConstantUndefined: self
]

{ #category : #testing }
SLVMConstantUndefined >> isUndefined [
	^ true
]

{ #category : #printing }
SLVMConstantUndefined >> mnemonic [
	^ #undefined
]

{ #category : #accessing }
SLVMConstantUndefined >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantUndefined >> type: anObject [
	type := anObject
]
