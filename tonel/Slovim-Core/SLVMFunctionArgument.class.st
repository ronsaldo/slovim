"
I represent a function argument.
"
Class {
	#name : #SLVMFunctionArgument,
	#superclass : #SLVMFunctionLocalValue,
	#instVars : [
		'type',
		'index',
		'livenessIndex'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMFunctionArgument class >> mnemonics [
	^ #()
]

{ #category : #visitor }
SLVMFunctionArgument >> accept: aVisitor [
	^ aVisitor visitFunctionArgument: self
]

{ #category : #printing }
SLVMFunctionArgument >> asFullSExpression [
	^ { name . type asSExpression . self flags sorted }
]

{ #category : #'as yet unclassified' }
SLVMFunctionArgument >> decodeFromSExpression: encodedValue context: context [
	flags := encodedValue third.
]

{ #category : #accessing }
SLVMFunctionArgument >> index [
	^ index
]

{ #category : #accessing }
SLVMFunctionArgument >> index: anObject [
	index := anObject
]

{ #category : #testing }
SLVMFunctionArgument >> isFunctionArgument [
	^ true
]

{ #category : #accessing }
SLVMFunctionArgument >> isReceiver [
	^ self hasFlag: #receiver
]

{ #category : #testing }
SLVMFunctionArgument >> isStructReturnPointer [
	^ self hasFlag: #sret
]

{ #category : #accessing }
SLVMFunctionArgument >> livenessIndex [
	^ livenessIndex
]

{ #category : #accessing }
SLVMFunctionArgument >> livenessIndex: anObject [
	livenessIndex := anObject
]

{ #category : #accessing }
SLVMFunctionArgument >> makeReceiver [
	self addFlag: #receiver
]

{ #category : #testing }
SLVMFunctionArgument >> markStructReturnPointer [
	^ self addFlag: #sret
]

{ #category : #accessing }
SLVMFunctionArgument >> name [
	^ name
]

{ #category : #accessing }
SLVMFunctionArgument >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMFunctionArgument >> type [
	^ type
]

{ #category : #accessing }
SLVMFunctionArgument >> type: anObject [
	type := anObject
]
