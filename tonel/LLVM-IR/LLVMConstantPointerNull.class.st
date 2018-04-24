Class {
	#name : #LLVMConstantPointerNull,
	#superclass : #LLVMConstantData,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstantPointerNull >> printOn: aStream [
	aStream nextPutAll: 'null'
]
