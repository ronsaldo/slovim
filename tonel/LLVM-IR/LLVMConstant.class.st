Class {
	#name : #LLVMConstant,
	#superclass : #LLVMUser,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstant >> printOn: aStream [
	self subclassResponsibility
]
