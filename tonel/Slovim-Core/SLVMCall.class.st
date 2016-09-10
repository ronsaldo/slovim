Class {
	#name : #SLVMCall,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'functionType'
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

{ #category : #accessing }
SLVMCall >> callingConvention [
	^ functionType callingConvention
]

{ #category : #construction }
SLVMCall >> function: functionValue arguments: arguments [
	self parameters: { functionValue } , arguments.
	self assert: functionValue type isPointerType.
	self assert: functionValue type baseType isFunctionType.
	functionType := functionValue type baseType.
	type := functionValue type baseType returnType.
	
]

{ #category : #accessing }
SLVMCall >> functionType [
	^ functionType
]

{ #category : #accessing }
SLVMCall >> functionValue [
	^ parameters first
]

{ #category : #testing }
SLVMCall >> hasOutputs [
	^ type isVoidType not
]

{ #category : #testing }
SLVMCall >> isCall [
	^ true
]

{ #category : #printing }
SLVMCall >> mnemonic [
	^ 'call'
]

{ #category : #accessing }
SLVMCall >> type [
	^ type
]
