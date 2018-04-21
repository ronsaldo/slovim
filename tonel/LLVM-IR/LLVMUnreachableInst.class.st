Class {
	#name : #LLVMUnreachableInst,
	#superclass : #LLVMTerminatorInst,
	#category : #'LLVM-IR'
}

{ #category : #printing }
LLVMUnreachableInst >> mnemonic [
	^ #unreachable
]

{ #category : #printing }
LLVMUnreachableInst >> printParametersOn: aStream [
	"Nothing required here"
]
