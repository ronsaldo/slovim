Class {
	#name : #LLVMDIType,
	#superclass : #LLVMDIScope,
	#instVars : [
		'size',
		'align'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIType >> align [
	^ align
]

{ #category : #accessing }
LLVMDIType >> align: anObject [
	align := anObject
]

{ #category : #accessing }
LLVMDIType >> size [
	^ size
]

{ #category : #accessing }
LLVMDIType >> size: anObject [
	size := anObject
]

{ #category : #accessing }
LLVMDIType >> specializedName [
	^ #DIType
]

{ #category : #accessing }
LLVMDIType >> specializedProperties [
	^ super specializedProperties , #( size align )
]
