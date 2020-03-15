Class {
	#name : #SLVMConstantFunctionExitPoint,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'sourceMethod'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantFunctionExitPoint class >> mnemonic [
	^ #functionExitPoint
]

{ #category : #comparing }
SLVMConstantFunctionExitPoint >> = other [
	^ self class = other class and: [ sourceMethod == other sourceMethod ]
]

{ #category : #visiting }
SLVMConstantFunctionExitPoint >> accept: aVisitor [
	^ aVisitor visitConstantFunctionExitPoint: self
]

{ #category : #comparing }
SLVMConstantFunctionExitPoint >> hash [
	^ self class hash bitXor: sourceMethod identityHash
]

{ #category : #testing }
SLVMConstantFunctionExitPoint >> isFunctionExitPoint [
	^ true
]

{ #category : #accessing }
SLVMConstantFunctionExitPoint >> sourceMethod [
	^ sourceMethod
]

{ #category : #accessing }
SLVMConstantFunctionExitPoint >> sourceMethod: anObject [
	sourceMethod := anObject
]

{ #category : #accessing }
SLVMConstantFunctionExitPoint >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantFunctionExitPoint >> type: anObject [
	type := anObject
]
