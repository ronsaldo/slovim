Class {
	#name : #SLVMCall,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMCall class >> function: functionValue arguments: arguments [
	^ self new function: functionValue arguments: arguments
]

{ #category : #visitor }
SLVMCall >> accept: aVisitor [
	^ aVisitor visitCall: self
]

{ #category : #accessing }
SLVMCall >> arguments [
	^ parameters allButFirst
]

{ #category : #construction }
SLVMCall >> function: functionValue arguments: arguments [
	self parameters: { functionValue } , arguments.
	self assert: functionValue type isReferenceType.
	self assert: functionValue type baseType isFunctionType.
	type := functionValue type baseType returnType
]

{ #category : #accessing }
SLVMCall >> functionValue [
	^ parameters first
]

{ #category : #printing }
SLVMCall >> mnemonic [
	^ 'call'
]

{ #category : #accessing }
SLVMCall >> type [
	^ type
]
