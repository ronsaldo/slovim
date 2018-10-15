Class {
	#name : #LLVMConstantZeroInitializer,
	#superclass : #LLVMConstant,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstantZeroInitializer >> printOn: aStream [
	aStream nextPutAll: 'zeroinitializer'
]
