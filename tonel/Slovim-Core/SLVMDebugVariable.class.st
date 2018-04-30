Class {
	#name : #SLVMDebugVariable,
	#superclass : #SLVMDebugValue,
	#instVars : [
		'argumentIndex'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #accessing }
SLVMDebugVariable >> argumentIndex [
	^ argumentIndex
]

{ #category : #accessing }
SLVMDebugVariable >> argumentIndex: anObject [
	argumentIndex := anObject
]
