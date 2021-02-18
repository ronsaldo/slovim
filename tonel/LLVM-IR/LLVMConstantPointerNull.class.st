Class {
	#name : #LLVMConstantPointerNull,
	#superclass : #LLVMConstantData,
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMConstantPointerNull >> buildHandle [
	handle := type validHandle constPointerNull
]

{ #category : #printing }
LLVMConstantPointerNull >> printOn: aStream [
	aStream nextPutAll: 'null'
]
