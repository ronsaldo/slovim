Class {
	#name : #LLVMDICompositeType,
	#superclass : #LLVMDIType,
	#instVars : [
		'tag',
		'elements',
		'baseType',
		'identifier'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDICompositeType >> baseType [
	^ baseType
]

{ #category : #accessing }
LLVMDICompositeType >> baseType: anObject [
	baseType := anObject
]

{ #category : #accessing }
LLVMDICompositeType >> elements [
	^ elements
]

{ #category : #accessing }
LLVMDICompositeType >> elements: anObject [
	elements := anObject
]

{ #category : #accessing }
LLVMDICompositeType >> identifier [
	^ identifier
]

{ #category : #accessing }
LLVMDICompositeType >> identifier: anObject [
	identifier := anObject
]

{ #category : #accessing }
LLVMDICompositeType >> specializedName [
	^ #DICompositeType
]

{ #category : #accessing }
LLVMDICompositeType >> specializedProperties [
	^ super specializedProperties , #(tag elements baseType identifier)
]

{ #category : #accessing }
LLVMDICompositeType >> tag [
	^ tag
]

{ #category : #accessing }
LLVMDICompositeType >> tag: anObject [
	tag := anObject
]
