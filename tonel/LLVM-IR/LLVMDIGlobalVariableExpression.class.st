Class {
	#name : #LLVMDIGlobalVariableExpression,
	#superclass : #LLVMMDNode,
	#instVars : [
		'var',
		'expr'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'as yet unclassified' }
LLVMDIGlobalVariableExpression >> doConcretizeWithDIBuilder: builder [
	| validName validLinkageName |
	validName := var name ifNil: [ '' ].
	validLinkageName := var linkageName ifNil: [ '' ].
	handle := builder createGlobalVariableExpressionIn: var scope
		name: validName nameLen: validName size
		linkage: validLinkageName len: validLinkageName size
		file: var file validHandle line: var line
		type: var type validHandle localToUnit: var isLocal
		expr: expr validHandle decl: LLVMMetadataRef null align: 0.
	var replaceHandleAllUsesWith: handle getVariableFromGlobalExpression
]

{ #category : #accessing }
LLVMDIGlobalVariableExpression >> expr [
	^ expr
]

{ #category : #accessing }
LLVMDIGlobalVariableExpression >> expr: anObject [
	expr := anObject
]

{ #category : #accessing }
LLVMDIGlobalVariableExpression >> specializedName [
	^ #DIGlobalVariableExpression
]

{ #category : #accessing }
LLVMDIGlobalVariableExpression >> specializedProperties [
	^ #(var expr)
]

{ #category : #accessing }
LLVMDIGlobalVariableExpression >> var [
	^ var
]

{ #category : #accessing }
LLVMDIGlobalVariableExpression >> var: anObject [
	var := anObject
]
