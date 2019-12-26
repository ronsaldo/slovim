Class {
	#name : #SLVMDebugScope,
	#superclass : #SLVMDebugInformation,
	#instVars : [
		'name',
		'parentScope'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #accessing }
SLVMDebugScope >> name [
	^ name
]

{ #category : #accessing }
SLVMDebugScope >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMDebugScope >> parentScope [
	^ parentScope
]

{ #category : #accessing }
SLVMDebugScope >> parentScope: anObject [
	parentScope := anObject
]

{ #category : #accessing }
SLVMDebugScope >> scope [
	^ self
]
