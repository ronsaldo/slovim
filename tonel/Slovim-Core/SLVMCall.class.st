Class {
	#name : #SLVMCall,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'functionType',
		'flags'
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

{ #category : #adding }
SLVMCall >> addFlag: flag [
	flags := flags copyWith: flag
	
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

{ #category : #flags }
SLVMCall >> hasFlag: flag [
	^ flags includes: flag
	
]

{ #category : #testing }
SLVMCall >> hasOutputs [
	^ type isVoidType not
]

{ #category : #initialization }
SLVMCall >> initialize [
	super initialize.
	flags := #()
]

{ #category : #testing }
SLVMCall >> isCall [
	^ true
]

{ #category : #testing }
SLVMCall >> isDynamicObjectReferenceCreator [
	^ true
]

{ #category : #flags }
SLVMCall >> isPrimitiveCall [
	^ self hasFlag: #primitiveCall
]

{ #category : #printing }
SLVMCall >> mnemonic [
	^ 'call'
]

{ #category : #flags }
SLVMCall >> setPrimitiveCall [
	^ self addFlag: #primitiveCall
]

{ #category : #accessing }
SLVMCall >> type [
	^ type
]
