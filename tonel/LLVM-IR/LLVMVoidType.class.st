Class {
	#name : #LLVMVoidType,
	#superclass : #LLVMOpaqueType,
	#category : #'LLVM-IR'
}

{ #category : #'as yet unclassified' }
LLVMVoidType >> initialize [
	super initialize.
	self name: #void
]

{ #category : #testing }
LLVMVoidType >> isVoidTy [
	^ true
]
