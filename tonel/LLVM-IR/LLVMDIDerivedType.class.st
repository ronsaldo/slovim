Class {
	#name : #LLVMDIDerivedType,
	#superclass : #LLVMDIType,
	#instVars : [
		'tag',
		'baseType',
		'offset'
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
LLVMDIDerivedType >> offset [
	^ offset
]

{ #category : #accessing }
LLVMDIDerivedType >> offset: anObject [
	offset := anObject
]

{ #category : #accessing }
LLVMDIDerivedType >> requiredProperties [
	^ #(baseType)
]

{ #category : #accessing }
LLVMDIDerivedType >> specializedName [
	^ #DIDerivedType
]

{ #category : #accessing }
LLVMDIDerivedType >> specializedProperties [
	^ super specializedProperties , #(tag baseType offset)
]

{ #category : #accessing }
LLVMDIDerivedType >> tag [
	^ tag
]

{ #category : #accessing }
LLVMDIDerivedType >> tag: anObject [
	tag := anObject
]
