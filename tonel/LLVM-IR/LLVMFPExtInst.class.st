Class {
	#name : #LLVMFPExtInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMFPExtInst >> mnemonic [
	^ #fpext
]
