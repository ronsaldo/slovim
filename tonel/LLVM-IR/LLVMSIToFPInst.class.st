Class {
	#name : #LLVMSIToFPInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMSIToFPInst >> mnemonic [
	^ #sitofp
]
