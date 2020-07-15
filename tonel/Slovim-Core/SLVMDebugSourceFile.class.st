Class {
	#name : #SLVMDebugSourceFile,
	#superclass : #SLVMDebugInformation,
	#instVars : [
		'name',
		'directory',
		'fileReference'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #'instance creation' }
SLVMDebugSourceFile class >> null [
	^ self new name: #anon; directory: ''
]

{ #category : #accessing }
SLVMDebugSourceFile >> asFileReference [
	^ fileReference ifNil: [fileReference := directory asFileReference / name]
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
SLVMDebugSourceFile >> fullname [
	^ self asFileReference fullName
]

{ #category : #accessing }
SLVMDebugSourceFile >> md5Checksum [
	^ ((self asFileReference
		binaryReadStreamDo: [ :in | MD5 hashStream: in ]
		ifAbsent: [MD5 hashMessage: #[]])) hex
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
