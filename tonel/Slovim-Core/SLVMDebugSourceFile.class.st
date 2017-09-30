Class {
	#name : #SLVMDebugSourceFile,
	#superclass : #SLVMDebugInformation,
	#instVars : [
		'name',
		'directory'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #'instance creation' }
SLVMDebugSourceFile class >> null [
	^ self new name: #anon; directory: ''
]

{ #category : #accessing }
SLVMDebugSourceFile >> directory [
	^ directory
]

{ #category : #accessing }
SLVMDebugSourceFile >> directory: anObject [
	directory := anObject
]

{ #category : #accessing }
SLVMDebugSourceFile >> name [
	^ name
]

{ #category : #accessing }
SLVMDebugSourceFile >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMDebugSourceFile >> printOn: aStream [
	aStream print: name
]
