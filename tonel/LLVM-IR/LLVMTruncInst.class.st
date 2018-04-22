Class {
	#name : #LLVMTruncInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMTruncInst >> mnemonic [
	^ #trunc
]
