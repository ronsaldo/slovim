Class {
	#name : #LLVMFPTruncInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMFPTruncInst >> mnemonic [
	^ #fptrunc
]
