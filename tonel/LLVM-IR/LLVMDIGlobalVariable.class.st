Class {
	#name : #LLVMDIGlobalVariable,
	#superclass : #LLVMDIVariable,
	#instVars : [
		'linkageName',
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
LLVMDIGlobalVariable >> linkageName [
	^ linkageName
]

{ #category : #accessing }
LLVMDIGlobalVariable >> linkageName: anObject [
	linkageName := anObject
]

{ #category : #accessing }
LLVMDIGlobalVariable >> specializedName [
	^ #DIGlobalVariable
]

{ #category : #accessing }
LLVMDIGlobalVariable >> specializedProperties [
	^ super specializedProperties , #(linkageName isDefinition isLocal)
]
