Class {
	#name : #LLVMUndefValue,
	#superclass : #LLVMConstantData,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMUndefValue >> printOn: aStream [
	^ aStream nextPutAll: 'undef'
]
