Class {
	#name : #SLVMFunctionLocalValue,
	#superclass : #SLVMValue,
	#instVars : [
		'debugInformation',
		'debugSourceLocation'
	],
	#category : #'Slovim-Core-SSA'
}

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
SLVMFunctionLocalValue >> isFunctionLocalValue [
	^ true
]
