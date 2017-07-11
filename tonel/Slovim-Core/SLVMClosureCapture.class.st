Class {
	#name : #SLVMClosureCapture,
	#superclass : #SLVMFunctionLocalValue,
	#instVars : [
		'function',
		'type',
		'index'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMClosureCapture >> function [
	^ function
]

{ #category : #accessing }
SLVMClosureCapture >> function: anObject [
	function := anObject
]

{ #category : #accessing }
SLVMClosureCapture >> index [
	^ index
]

{ #category : #accessing }
SLVMClosureCapture >> index: anObject [
	index := anObject
]

{ #category : #testing }
SLVMClosureCapture >> isClosureCapture [
	^ true
]

{ #category : #printing }
SLVMClosureCapture >> printOn: aStream [
	aStream nextPutAll: 'closureCapture '; print: index
]

{ #category : #accessing }
SLVMClosureCapture >> type [
	^ type
]

{ #category : #accessing }
SLVMClosureCapture >> type: anObject [
	type := anObject
]
