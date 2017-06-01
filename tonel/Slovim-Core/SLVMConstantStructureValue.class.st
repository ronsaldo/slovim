Class {
	#name : #SLVMConstantStructureValue,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'slots'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantStructureValue >> accept: aVisitor [
	^ aVisitor visitConstantStructureValue: self
]

{ #category : #testing }
SLVMConstantStructureValue >> isConstantStructureValue [
	^ true
]

{ #category : #accessing }
SLVMConstantStructureValue >> slots [
	^ slots
]

{ #category : #accessing }
SLVMConstantStructureValue >> slots: anObject [
	slots := anObject
]

{ #category : #accessing }
SLVMConstantStructureValue >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantStructureValue >> type: anObject [
	type := anObject
]
