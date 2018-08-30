"
I represent a constant value.
"
Class {
	#name : #SLVMConstantValue,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'value'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #arithmetic }
SLVMConstantValue >> + other [
	self assert: other isConstantValue.
	^ self copy value: value + other value
]

{ #category : #arithmetic }
SLVMConstantValue >> - other [
	self assert: other isConstantValue.
	^ self copy value: value - other value
]

{ #category : #comparing }
SLVMConstantValue >> = other [
	^ self class = other class and: [ self type = other type and: [ self value = other value and: [self value class == other value class ] ] ]
]

{ #category : #visitor }
SLVMConstantValue >> accept: aVisitor [
	^ aVisitor visitConstantValue: self
]

{ #category : #converting }
SLVMConstantValue >> asBlob [
	^ ByteArray streamContents: [ :out | type encodeConstant: value bigEndian: false intoByteStream: out ]
]

{ #category : #comparing }
SLVMConstantValue >> hash [
	^ ((self class hash bitXor: type hash) bitXor: value hash) bitXor: value class identityHash
]

{ #category : #testing }
SLVMConstantValue >> isConstantValue [
	^ true
]

{ #category : #testing }
SLVMConstantValue >> isOneConstant [
	^ value = 1
]

{ #category : #testing }
SLVMConstantValue >> isZeroConstant [
	^ value = 0
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
