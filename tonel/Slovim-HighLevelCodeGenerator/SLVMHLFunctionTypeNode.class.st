Class {
	#name : #SLVMHLFunctionTypeNode,
	#superclass : #SLVMHLTypeNode,
	#instVars : [
		'returnType',
		'arguments'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLFunctionTypeNode >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMHLFunctionTypeNode >> arguments: anObject [
	arguments := anObject
]

{ #category : #accessing }
SLVMHLFunctionTypeNode >> returnType [
	^ returnType
]

{ #category : #accessing }
SLVMHLFunctionTypeNode >> returnType: anObject [
	returnType := anObject
]
