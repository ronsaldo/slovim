Class {
	#name : #SLVMConstantGlobalVariableHeaderReference,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'globalVariable'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #comparing }
SLVMConstantGlobalVariableHeaderReference >> = other [
	^ self class = other class and: [ globalVariable == other globalVariable and: [ type = other type] ]
]

{ #category : #visiting }
SLVMConstantGlobalVariableHeaderReference >> accept: aVisitor [
	^ aVisitor visitConstantGlobalVariableHeaderReference: self
]

{ #category : #accessing }
SLVMConstantGlobalVariableHeaderReference >> globalVariable [
	^ globalVariable
]

{ #category : #accessing }
SLVMConstantGlobalVariableHeaderReference >> globalVariable: anObject [
	globalVariable := anObject
]

{ #category : #comparing }
SLVMConstantGlobalVariableHeaderReference >> hash [
	^ self class hash bitXor: (globalVariable identityHash bitXor: type hash)
]

{ #category : #accessing }
SLVMConstantGlobalVariableHeaderReference >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantGlobalVariableHeaderReference >> type: anObject [
	type := anObject
]
