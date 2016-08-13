Class {
	#name : #SLVMFunctionArgument,
	#superclass : #SLVMValue,
	#instVars : [
		'type',
		'index',
		'name'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMFunctionArgument >> accept: aVisitor [
	^ aVisitor visitFunctionArgument: self
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
