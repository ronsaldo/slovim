Class {
	#name : #LLVMDILocalVariable,
	#superclass : #LLVMDIVariable,
	#instVars : [
		'arg',
		'flags'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDILocalVariable >> arg [
	^ arg
]

{ #category : #accessing }
LLVMDILocalVariable >> arg: anObject [
	arg := anObject
]

{ #category : #accessing }
LLVMDILocalVariable >> flags [
	^ flags
]

{ #category : #accessing }
LLVMDILocalVariable >> flags: anObject [
	flags := anObject
]

{ #category : #accessing }
LLVMDILocalVariable >> specializedName [
	^ #DILocalVariable
]

{ #category : #accessing }
LLVMDILocalVariable >> specializedProperties [
	^ super specializedProperties , #( arg flags )
]
