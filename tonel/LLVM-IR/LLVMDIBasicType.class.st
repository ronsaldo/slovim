Class {
	#name : #LLVMDIBasicType,
	#superclass : #LLVMDIType,
	#instVars : [
		'encoding'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIBasicType >> encoding [
	^ encoding
]

{ #category : #accessing }
LLVMDIBasicType >> encoding: anObject [
	encoding := anObject
]

{ #category : #accessing }
LLVMDIBasicType >> specializedName [
	^ #DIBasicType
]

{ #category : #accessing }
LLVMDIBasicType >> specializedProperties [
	^ super specializedProperties , #(encoding)
]
