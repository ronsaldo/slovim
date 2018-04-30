Class {
	#name : #LLVMConstant,
	#superclass : #LLVMUser,
	#category : #'LLVM-IR-Constants'
}

{ #category : #converting }
LLVMConstant >> asLLVMMetadata [
	^ LLVMConstantAsMetadata new constant: self
]

{ #category : #printing }
LLVMConstant >> printOn: aStream [
	self subclassResponsibility
]
