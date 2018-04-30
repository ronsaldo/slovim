Class {
	#name : #LLVMDIDerivedType,
	#superclass : #LLVMDIType,
	#instVars : [
		'tag',
		'baseType'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIDerivedType >> baseType [
	^ baseType
]

{ #category : #accessing }
LLVMDIDerivedType >> baseType: anObject [
	baseType := anObject
]

{ #category : #accessing }
LLVMDIDerivedType >> specializedName [
	^ #DIDerivedType
]

{ #category : #accessing }
LLVMDIDerivedType >> specializedProperties [
	^ super specializedProperties , #(tag baseType)
]

{ #category : #accessing }
LLVMDIDerivedType >> tag [
	^ tag
]

{ #category : #accessing }
LLVMDIDerivedType >> tag: anObject [
	tag := anObject
]
