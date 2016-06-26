Class {
	#name : #SLVMLoadInstruction,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMLoadInstruction class >> variable: variableReference [
	^ self new variable: variableReference
]

{ #category : #visitor }
SLVMLoadInstruction >> accept: aVisitor [
	^ aVisitor visitLoad: self
]

{ #category : #testing }
SLVMLoadInstruction >> isLoad [
	^ true
]

{ #category : #printing }
SLVMLoadInstruction >> mnemonic [
	^ 'load'
]

{ #category : #accessing }
SLVMLoadInstruction >> type [
	^ type
]

{ #category : #accessing }
SLVMLoadInstruction >> variable [
	^ parameters first
]

{ #category : #accessing }
SLVMLoadInstruction >> variable: variableReference [
	| refType |
	self parameters: { variableReference }.
	refType := variableReference type.
	self assert: refType isReferenceType.
	type := refType baseType.
]