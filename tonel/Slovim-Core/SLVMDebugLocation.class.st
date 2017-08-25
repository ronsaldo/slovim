Class {
	#name : #SLVMDebugLocation,
	#superclass : #SLVMDebugInformation,
	#instVars : [
		'sourceFile',
		'startLine',
		'startColumn',
		'endLine',
		'endColumn'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #accessing }
SLVMDebugLocation >> endColumn [
	^ endColumn
]

{ #category : #accessing }
SLVMDebugLocation >> endColumn: anObject [
	endColumn := anObject
]

{ #category : #accessing }
SLVMDebugLocation >> endLine [
	^ endLine
]

{ #category : #accessing }
SLVMDebugLocation >> endLine: anObject [
	endLine := anObject
]

{ #category : #printing }
SLVMDebugLocation >> printOn: aStream [
	aStream print: sourceFile; space; print: startColumn; space; print: startLine
]

{ #category : #accessing }
SLVMDebugLocation >> sourceFile [
	^ sourceFile
]

{ #category : #accessing }
SLVMDebugLocation >> sourceFile: anObject [
	sourceFile := anObject
]

{ #category : #accessing }
SLVMDebugLocation >> startColumn [
	^ startColumn
]

{ #category : #accessing }
SLVMDebugLocation >> startColumn: anObject [
	startColumn := anObject
]

{ #category : #accessing }
SLVMDebugLocation >> startLine [
	^ startLine
]

{ #category : #accessing }
SLVMDebugLocation >> startLine: anObject [
	startLine := anObject
]
