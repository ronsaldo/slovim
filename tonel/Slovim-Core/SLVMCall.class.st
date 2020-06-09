"
I represent a function call.
"
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

{ #category : #printing }
SLVMCall class >> mnemonic [
	^ #call
]

{ #category : #visitor }
SLVMCall >> accept: aVisitor [
	^ aVisitor visitCall: self
]

{ #category : #adding }
SLVMCall >> addFlag: flag [
	flags := self flags copyWith: flag
	
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
	
]

{ #category : #accessing }
SLVMCall >> functionType [
	^ functionType ifNil: [ functionType := self functionValue type baseType. ]
]

{ #category : #accessing }
SLVMCall >> functionValue [
	^ parameters first
]

{ #category : #testing }
SLVMCall >> hasOutputs [
	^ type isVoidType not
]

{ #category : #initialization }
SLVMCall >> hasSRet [
	^ self hasFlag: #sret
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

{ #category : #flags }
SLVMCall >> setPrimitiveCall [
	^ self addFlag: #primitiveCall
]

{ #category : #initialization }
SLVMCall >> setSRetPresence [
	self addFlag: #sret.
]

{ #category : #accessing }
SLVMCall >> type [
	^ type ifNil: [ type := self functionType returnType. ]
]
