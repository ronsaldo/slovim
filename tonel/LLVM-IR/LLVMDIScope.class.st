Class {
	#name : #LLVMDIScope,
	#superclass : #LLVMDINode,
	#instVars : [
		'name',
		'scope',
		'file',
		'flags',
		'extraData'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIScope >> extraData [
	^ extraData
]

{ #category : #accessing }
LLVMDIScope >> extraData: anObject [
	extraData := anObject
]

{ #category : #accessing }
LLVMDIScope >> file [
	^ file
]

{ #category : #accessing }
LLVMDIScope >> file: anObject [
	file := anObject
]

{ #category : #accessing }
LLVMDIScope >> flags [
	^ flags
]

{ #category : #accessing }
LLVMDIScope >> flags: anObject [
	flags := anObject
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
	^ #(name scope file flags extraData)
]
