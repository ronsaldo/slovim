"
I represent a function argument.
"
Class {
	#name : #SLVMFunctionArgument,
	#superclass : #SLVMFunctionLocalValue,
	#instVars : [
		'function',
		'type',
		'index',
		'name',
		'livenessIndex'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMFunctionArgument >> accept: aVisitor [
	^ aVisitor visitFunctionArgument: self
]

{ #category : #accessing }
SLVMFunctionArgument >> function [
	^ function
]

{ #category : #accessing }
SLVMFunctionArgument >> function: anObject [
	function := anObject
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

{ #category : #printing }
SLVMFunctionArgument >> printOn: aStream [
	^ aStream nextPut: $%; nextPutAll: name
]

{ #category : #accessing }
SLVMFunctionArgument >> type [
	^ type
]

{ #category : #accessing }
SLVMFunctionArgument >> type: anObject [
	type := anObject
]
