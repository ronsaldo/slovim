Class {
	#name : #LLVMFPToSIInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMFPToSIInst >> mnemonic [
	^ #fptosi
]
