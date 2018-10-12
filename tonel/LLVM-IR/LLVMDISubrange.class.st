Class {
	#name : #LLVMDISubrange,
	#superclass : #LLVMDINode,
	#instVars : [
		'count'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDISubrange >> count [
	^ count
]

{ #category : #accessing }
LLVMDISubrange >> count: anObject [
	count := anObject
]

{ #category : #accessing }
LLVMDISubrange >> specializedName [
	^ #DISubrange
]

{ #category : #accessing }
LLVMDISubrange >> specializedProperties [
	^ #( count )
]
