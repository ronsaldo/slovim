Class {
	#name : #LLVMDILocalVariable,
	#superclass : #LLVMDIVariable,
	#instVars : [
		'arg'
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
LLVMDILocalVariable >> specializedName [
	^ #DILocalVariable
]

{ #category : #accessing }
LLVMDILocalVariable >> specializedProperties [
	^ super specializedProperties , #( arg )
]
