Class {
	#name : #LLVMDICompositeType,
	#superclass : #LLVMDIType,
	#instVars : [
		'tag',
		'elements'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDICompositeType >> elements [
	^ elements
]

{ #category : #accessing }
LLVMDICompositeType >> elements: anObject [
	elements := anObject
]

{ #category : #accessing }
LLVMDICompositeType >> specializedName [
	^ #DICompositeType
]

{ #category : #accessing }
LLVMDICompositeType >> specializedProperties [
	^ super specializedProperties , #(tag elements)
]

{ #category : #accessing }
LLVMDICompositeType >> tag [
	^ tag
]

{ #category : #accessing }
LLVMDICompositeType >> tag: anObject [
	tag := anObject
]
