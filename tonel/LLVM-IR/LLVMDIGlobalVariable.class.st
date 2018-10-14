Class {
	#name : #LLVMDIGlobalVariable,
	#superclass : #LLVMDIVariable,
	#instVars : [
		'isLocal',
		'isDefinition'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIGlobalVariable >> isDefinition [
	^ isDefinition
]

{ #category : #accessing }
LLVMDIGlobalVariable >> isDefinition: anObject [
	isDefinition := anObject
]

{ #category : #accessing }
LLVMDIGlobalVariable >> isLocal [
	^ isLocal
]

{ #category : #accessing }
LLVMDIGlobalVariable >> isLocal: anObject [
	isLocal := anObject
]

{ #category : #accessing }
LLVMDIGlobalVariable >> specializedName [
	^ #DIGlobalVariable
]

{ #category : #accessing }
LLVMDIGlobalVariable >> specializedProperties [
	^ super specializedProperties , #(isDefinition isLocal)
]
