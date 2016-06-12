Class {
	#name : #SLVMConstantValue,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'value'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #comparing }
SLVMConstantValue >> = other [
	^ self class = other class and: [ self type = other type and: [ self value = other value ] ]
]

{ #category : #visitor }
SLVMConstantValue >> accept: aVisitor [
	^ aVisitor visitConstantValue: self
]

{ #category : #comparing }
SLVMConstantValue >> hash [
	^ (self class hash bitXor: type hash) bitXor: value hash
]

{ #category : #testing }
SLVMConstantValue >> isConstantValue [
	^ true
]

{ #category : #printing }
SLVMConstantValue >> printOn: aStream [
	aStream nextPutAll: 'constant '; print: type; space; print: value
]

{ #category : #accessing }
SLVMConstantValue >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantValue >> type: aType [
	self assert: aType isSlovimType.
	type := aType.
]

{ #category : #accessing }
SLVMConstantValue >> value [
	^ value
]

{ #category : #accessing }
SLVMConstantValue >> value: anObject [
	value := anObject
]
