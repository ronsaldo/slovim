"
I represent a node in an intermediate representation for a high-level language code.
"
Class {
	#name : #SLVMHLCodeNode,
	#superclass : #Object,
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMHLCodeNode >> isArrayType [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMHLCodeNode >> isStructureType [
	^ false
]

{ #category : #converting }
SLVMHLCodeNode >> translateValueWith: translator [
	self subclassResponsibility
]

{ #category : #converting }
SLVMHLCodeNode >> translateWith: translator [
	self subclassResponsibility
]
