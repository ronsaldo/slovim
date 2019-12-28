Class {
	#name : #SLVMDebugLexicalScope,
	#superclass : #SLVMDebugLocalScope,
	#instVars : [
		'file',
		'startLine',
		'endLine',
		'startColumn',
		'endColumn'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugLexicalScope >> accept: visitor [
	^ visitor visitDebugLexicalScope: self
]

{ #category : #accessing }
SLVMDebugLexicalScope >> endColumn [
	^ endColumn
]

{ #category : #accessing }
SLVMDebugLexicalScope >> endColumn: anObject [
	endColumn := anObject
]

{ #category : #accessing }
SLVMDebugLexicalScope >> endLine [
	^ endLine
]

{ #category : #accessing }
SLVMDebugLexicalScope >> endLine: anObject [
	endLine := anObject
]

{ #category : #accessing }
SLVMDebugLexicalScope >> file [
	^ file
]

{ #category : #accessing }
SLVMDebugLexicalScope >> file: anObject [
	file := anObject
]

{ #category : #accessing }
SLVMDebugLexicalScope >> startColumn [
	^ startColumn
]

{ #category : #accessing }
SLVMDebugLexicalScope >> startColumn: anObject [
	startColumn := anObject
]

{ #category : #accessing }
SLVMDebugLexicalScope >> startLine [
	^ startLine
]

{ #category : #accessing }
SLVMDebugLexicalScope >> startLine: anObject [
	startLine := anObject
]
