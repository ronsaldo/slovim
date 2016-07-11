"
I represent a node in an intermediate representation for a high-level language code.
"
Class {
	#name : #SLVMHLCodeNode,
	#superclass : #Object,
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #converting }
SLVMHLCodeNode >> translateWith: translator [
	self subclassResponsibility
]
