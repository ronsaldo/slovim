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

{ #category : #'basic optimizations' }
SLVMLoadInstruction >> foldConstant [
	| var |
	var := self variable.
	(var isGlobalValue and: [var isGlobalVariable and: [var readOnly]]) ifTrue: [ 
		var initialValue ifNotNil: [ :constant | ^ constant ]
	].
	
	^ super foldConstant
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
	self assert: refType isPointerType.
	type := refType baseType.
]
