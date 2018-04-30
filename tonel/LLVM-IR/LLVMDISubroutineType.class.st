Class {
	#name : #LLVMDISubroutineType,
	#superclass : #LLVMDIType,
	#instVars : [
		'types'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDISubroutineType >> specializedName [
	^ #DISubroutineType
]

{ #category : #accessing }
LLVMDISubroutineType >> specializedProperties [
	^ super specializedProperties , #( types )
]

{ #category : #accessing }
LLVMDISubroutineType >> types [
	^ types
]

{ #category : #accessing }
LLVMDISubroutineType >> types: anObject [
	types := anObject
]
