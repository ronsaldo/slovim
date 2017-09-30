Class {
	#name : #SLVMDebugLocation,
	#superclass : #SLVMDebugInformation,
	#instVars : [
		'sourceFile',
		'startLine',
		'startColumn',
		'endLine',
		'endColumn',
		'start',
		'stop'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #'instance creation' }
SLVMDebugLocation class >> null [
	^ self new
		start: 1; stop: 1;
		startLine: 1; startColumn: 1;
		endLine: 1; endColumn: 1;
		sourceFile: SLVMDebugSourceFile null;
		yourself
		
]

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
	aStream print: sourceFile; space; print: startLine; space; print: startColumn
]

{ #category : #accessing }
SLVMDebugLocation >> sourceFile [
	^ sourceFile
]

{ #category : #accessing }
SLVMDebugLocation >> sourceFile: anObject [
	sourceFile := anObject
]

{ #category : #inspector }
SLVMDebugLocation >> sourceInterval [
	^ start to: stop
]

{ #category : #accessing }
SLVMDebugLocation >> start [
	^ start
]

{ #category : #accessing }
SLVMDebugLocation >> start: anObject [
	start := anObject
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

{ #category : #accessing }
SLVMDebugLocation >> stop [
	^ stop
]

{ #category : #accessing }
SLVMDebugLocation >> stop: anObject [
	stop := anObject
]
