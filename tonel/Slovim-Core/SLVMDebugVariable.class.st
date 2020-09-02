Class {
	#name : #SLVMDebugVariable,
	#superclass : #SLVMDebugValue,
	#instVars : [
		'argumentIndex',
		'emitLinkageName'
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

{ #category : #accessing }
SLVMDebugVariable >> emitLinkageName [
	^ emitLinkageName ifNil: [ false ]
]

{ #category : #accessing }
SLVMDebugVariable >> emitLinkageName: anObject [
	emitLinkageName := anObject
]
