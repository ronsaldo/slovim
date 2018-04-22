Class {
	#name : #LLVMICmpInst,
	#superclass : #LLVMCmpInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMICmpInst >> mnemonic [
	^ #icmp
]
