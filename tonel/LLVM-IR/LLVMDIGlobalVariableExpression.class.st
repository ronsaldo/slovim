Class {
	#name : #LLVMDIGlobalVariableExpression,
	#superclass : #LLVMMDNode,
	#instVars : [
		'var',
		'expr'
	],
	#category : #'LLVM-IR-Metadata'
}

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
