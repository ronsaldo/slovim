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

{ #category : #'as yet unclassified' }
LLVMDIGlobalVariable >> doConcretizeWithDIBuilder: builder [
	| validName validLinkageName |
	validName := name ifNil: [ '' ].
	validLinkageName := linkageName ifNil: [ '' ].
	handle := builder createTempGlobalVariableFwdDeclIn: scope validHandle
		name: validName nameLen: validName size
		linkage: validLinkageName len: validLinkageName size
		file: file validHandle line: line type: type validHandle
		localToUnit: isLocal decl: LLVMMetadataRef null align: 0
]

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
