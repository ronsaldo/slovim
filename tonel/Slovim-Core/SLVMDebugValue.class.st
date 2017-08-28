Class {
	#name : #SLVMDebugValue,
	#superclass : #SLVMDebugInformation,
	#instVars : [
		'scope',
		'name'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #'as yet unclassified' }
SLVMDebugValue class >> scope: aScope name: aName [
	^ self new scope: aScope; name: aName; yourself
]

{ #category : #accessing }
SLVMDebugValue >> name [
	^ name
]

{ #category : #accessing }
SLVMDebugValue >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMDebugValue >> printOn: aStream [
	aStream nextPutAll: name
]

{ #category : #accessing }
SLVMDebugValue >> scope [
	^ scope
]

{ #category : #accessing }
SLVMDebugValue >> scope: anObject [
	scope := anObject
]
