Class {
	#name : #LLVMConstantAggregate,
	#superclass : #LLVMConstant,
	#instVars : [
		'elements'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMConstantAggregate >> elements [
	^ elements
]

{ #category : #accessing }
LLVMConstantAggregate >> elements: anObject [
	elements := anObject
]
