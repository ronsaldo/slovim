Class {
	#name : #SLVMHLFunctionPrototypeDeclarationNode,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'function'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLFunctionPrototypeDeclarationNode >> function [
	^ function
]

{ #category : #accessing }
SLVMHLFunctionPrototypeDeclarationNode >> function: anObject [
	function := anObject
]

{ #category : #accessing }
SLVMHLFunctionPrototypeDeclarationNode >> translateWith: translator [
	^ translator translateHLFunctionPrototypeDeclaration: self
]
