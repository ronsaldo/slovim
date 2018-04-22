Class {
	#name : #LLVMVoidType,
	#superclass : #LLVMOpaqueType,
	#category : #'LLVM-IR-Types'
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
