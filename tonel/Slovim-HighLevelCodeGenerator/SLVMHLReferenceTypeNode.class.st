Class {
	#name : #SLVMHLReferenceTypeNode,
	#superclass : #SLVMHLTypeNode,
	#instVars : [
		'name',
		'baseType'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLReferenceTypeNode >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMHLReferenceTypeNode >> baseType: anObject [
	baseType := anObject
]

{ #category : #testing }
SLVMHLReferenceTypeNode >> isReferenceType [
	^ true
]

{ #category : #accessing }
SLVMHLReferenceTypeNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLReferenceTypeNode >> name: anObject [
	name := anObject
]
