Class {
	#name : #SLVMConstantZeroInitializer,
	#superclass : #SLVMConstant,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMConstantZeroInitializer >> accept: aVisitor [
	^ aVisitor visitConstantZeroInitializer: self
]

{ #category : #accessing }
SLVMConstantZeroInitializer >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantZeroInitializer >> type: anObject [
	type := anObject
]
