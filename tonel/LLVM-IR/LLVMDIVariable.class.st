Class {
	#name : #LLVMDIVariable,
	#superclass : #LLVMDINode,
	#instVars : [
		'name',
		'scope',
		'file',
		'line',
		'type',
		'flags'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIVariable >> file [
	^ file
]

{ #category : #accessing }
LLVMDIVariable >> file: anObject [
	file := anObject
]

{ #category : #accessing }
LLVMDIVariable >> flags [
	^ flags
]

{ #category : #accessing }
LLVMDIVariable >> flags: anObject [
	flags := anObject
]

{ #category : #accessing }
LLVMDIVariable >> line [
	^ line
]

{ #category : #accessing }
LLVMDIVariable >> line: anObject [
	line := anObject
]

{ #category : #accessing }
LLVMDIVariable >> name [
	^ name
]

{ #category : #accessing }
LLVMDIVariable >> name: anObject [
	name := anObject
]

{ #category : #accessing }
LLVMDIVariable >> scope [
	^ scope
]

{ #category : #accessing }
LLVMDIVariable >> scope: anObject [
	scope := anObject
]

{ #category : #accessing }
LLVMDIVariable >> specializedProperties [
	^ #( name scope file line type flags )
]

{ #category : #accessing }
LLVMDIVariable >> type [
	^ type
]

{ #category : #accessing }
LLVMDIVariable >> type: anObject [
	type := anObject
]
