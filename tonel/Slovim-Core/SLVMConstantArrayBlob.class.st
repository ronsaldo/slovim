Class {
	#name : #SLVMConstantArrayBlob,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'data'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantArrayBlob class >> mnemonic [
	^ #constArrayBlob
]

{ #category : #visiting }
SLVMConstantArrayBlob >> accept: aVisitor [
	^ aVisitor visitConstantArrayBlob: self
]

{ #category : #converting }
SLVMConstantArrayBlob >> asBlob [
	^ data
]

{ #category : #printing }
SLVMConstantArrayBlob >> asSExpression [
	^ { self mnemonic . self asBlob }
]

{ #category : #accessing }
SLVMConstantArrayBlob >> data [
	^ data
]

{ #category : #accessing }
SLVMConstantArrayBlob >> data: anObject [
	data := anObject
]

{ #category : #testing }
SLVMConstantArrayBlob >> hasExtraNullCharacter [
	^ false
]

{ #category : #testing }
SLVMConstantArrayBlob >> isConstantArrayBlob [
	^ true
]

{ #category : #accessing }
SLVMConstantArrayBlob >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantArrayBlob >> type: anObject [
	type := anObject
]
