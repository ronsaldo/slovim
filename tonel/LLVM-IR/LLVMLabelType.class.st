Class {
	#name : #LLVMLabelType,
	#superclass : #LLVMOpaqueType,
	#category : #'LLVM-IR'
}

{ #category : #'as yet unclassified' }
LLVMLabelType >> initialize [
	super initialize.
	self name: #label
]

{ #category : #testing }
LLVMLabelType >> isLabelTy [
	^ true
]
