"
I represent a value that is only valid in the local scope of a function.
"
Class {
	#name : #SLVMFunctionLocalValue,
	#superclass : #SLVMValue,
	#instVars : [
		'debugInformation',
		'debugSourceLocation',
		'instructionReferences'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMFunctionLocalValue >> addInstructionReference: anInstruction [
	instructionReferences add: anInstruction
]

{ #category : #accessing }
SLVMFunctionLocalValue >> debugInformation [
	^ debugInformation
]

{ #category : #accessing }
SLVMFunctionLocalValue >> debugInformation: anObject [
	debugInformation := anObject
]

{ #category : #accessing }
SLVMFunctionLocalValue >> debugSourceLocation [
	^ debugSourceLocation
]

{ #category : #accessing }
SLVMFunctionLocalValue >> debugSourceLocation: anObject [
	debugSourceLocation := anObject
]

{ #category : #accessing }
SLVMFunctionLocalValue >> function [
	self subclassResponsibility
]

{ #category : #testing }
SLVMFunctionLocalValue >> hasReferences [
	^ instructionReferences isNotEmpty
]

{ #category : #initialization }
SLVMFunctionLocalValue >> initialize [
	instructionReferences := OrderedCollection new.
]

{ #category : #accessing }
SLVMFunctionLocalValue >> instructionReferences [
	^ instructionReferences
]

{ #category : #testing }
SLVMFunctionLocalValue >> isFunctionLocalValue [
	^ true
]

{ #category : #copying }
SLVMFunctionLocalValue >> postCopy [
	super postCopy.
	instructionReferences := OrderedCollection new.
]

{ #category : #adding }
SLVMFunctionLocalValue >> removeInstructionReference: anInstruction [
	instructionReferences removeAllSuchThat: [:el | el == anInstruction]
]
