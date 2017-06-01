Class {
	#name : #SLVMConstantArrayValue,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'slots'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantArrayValue >> accept: aVisitor [
	^ aVisitor visitConstantArrayValue: self
]

{ #category : #testing }
SLVMConstantArrayValue >> isConstantArrayValue [
	^ true
]

{ #category : #accessing }
SLVMConstantArrayValue >> slots [
	^ slots
]

{ #category : #accessing }
SLVMConstantArrayValue >> slots: anObject [
	slots := anObject
]

{ #category : #accessing }
SLVMConstantArrayValue >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantArrayValue >> type: anObject [
	type := anObject
]
