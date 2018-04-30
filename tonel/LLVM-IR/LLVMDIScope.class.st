Class {
	#name : #LLVMDIScope,
	#superclass : #LLVMDINode,
	#instVars : [
		'name',
		'scope',
		'file'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIScope >> file [
	^ file
]

{ #category : #accessing }
LLVMDIScope >> file: anObject [
	file := anObject
]

{ #category : #accessing }
LLVMDIScope >> name [
	^ name
]

{ #category : #accessing }
LLVMDIScope >> name: anObject [
	name := anObject
]

{ #category : #accessing }
LLVMDIScope >> scope [
	^ scope
]

{ #category : #accessing }
LLVMDIScope >> scope: anObject [
	scope := anObject
]

{ #category : #accessing }
LLVMDIScope >> specializedName [
	^ #DIScope
]

{ #category : #accessing }
LLVMDIScope >> specializedProperties [
	^ #(name scope file )
]
