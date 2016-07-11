Class {
	#name : #SLVMHLBasicTypeNode,
	#superclass : #SLVMHLTypeNode,
	#instVars : [
		'name',
		'type'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLBasicTypeNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLBasicTypeNode >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMHLBasicTypeNode >> type [
	^ type
]

{ #category : #accessing }
SLVMHLBasicTypeNode >> type: anObject [
	type := anObject
]
