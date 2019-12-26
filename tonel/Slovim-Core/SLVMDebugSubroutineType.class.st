Class {
	#name : #SLVMDebugSubroutineType,
	#superclass : #SLVMDebugType,
	#instVars : [
		'argumentTypes',
		'returnType'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugSubroutineType >> accept: visitor [
	^ visitor visitDebugSubroutineType: self
]

{ #category : #accessing }
SLVMDebugSubroutineType >> argumentTypes [
	^ argumentTypes
]

{ #category : #accessing }
SLVMDebugSubroutineType >> argumentTypes: anObject [
	argumentTypes := anObject
]

{ #category : #accessing }
SLVMDebugSubroutineType >> returnType [
	^ returnType
]

{ #category : #accessing }
SLVMDebugSubroutineType >> returnType: anObject [
	returnType := anObject
]
