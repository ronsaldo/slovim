Class {
	#name : #LLVMFCmpInst,
	#superclass : #LLVMCmpInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMFCmpInst >> mnemonic [
	^ #fcmp
]
