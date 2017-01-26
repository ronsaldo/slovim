Class {
	#name : #SLVMHLTypeNode,
	#superclass : #SLVMHLCodeNode,
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMHLTypeNode >> arrayBounds: unboundedCase [
	^ ''
]

{ #category : #testing }
SLVMHLTypeNode >> isReferenceType [
	^ false
]
