Class {
	#name : #LLVMConstant,
	#superclass : #LLVMUser,
	#category : #'LLVM-IR-Constants'
}

{ #category : #converting }
LLVMConstant >> asLLVMMetadata [
	^ LLVMConstantAsMetadata new constant: self
]

{ #category : #'as yet unclassified' }
LLVMConstant >> convertIntoCompactVectorType: compactVectorType [
	self error: 'Not supported here.'
]

{ #category : #printing }
LLVMConstant >> printOn: aStream [
	self subclassResponsibility
]
