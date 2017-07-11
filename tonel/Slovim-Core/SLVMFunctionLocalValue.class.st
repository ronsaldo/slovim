Class {
	#name : #SLVMFunctionLocalValue,
	#superclass : #SLVMValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMFunctionLocalValue >> function [
	self subclassResponsibility
]

{ #category : #testing }
SLVMFunctionLocalValue >> isFunctionLocalValue [
	^ true
]
