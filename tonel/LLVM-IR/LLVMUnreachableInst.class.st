Class {
	#name : #LLVMUnreachableInst,
	#superclass : #LLVMTerminatorInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMUnreachableInst >> buildHandleWithBuilder: builder [
	handle := builder unreachable
]

{ #category : #printing }
LLVMUnreachableInst >> mnemonic [
	^ #unreachable
]

{ #category : #printing }
LLVMUnreachableInst >> printParametersOn: aStream [
	"Nothing required here"
]
