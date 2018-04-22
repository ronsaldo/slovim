Class {
	#name : #LLVMUIToFPInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMUIToFPInst >> mnemonic [
	^ #uitofp
]
