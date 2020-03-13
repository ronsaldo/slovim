Class {
	#name : #SLVMConstantZeroInitializer,
	#superclass : #SLVMConstant,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantZeroInitializer class >> mnemonic [
	^ #zeroInitialized
]

{ #category : #visitor }
SLVMConstantZeroInitializer >> accept: aVisitor [
	^ aVisitor visitConstantZeroInitializer: self
]

{ #category : #printing }
SLVMConstantZeroInitializer >> asSExpression [
	^ { self mnemonic . type asSExpression }
]

{ #category : #accessing }
SLVMConstantZeroInitializer >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantZeroInitializer >> type: anObject [
	type := anObject
]
