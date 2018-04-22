Class {
	#name : #LLVMFPToUIInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMFPToUIInst >> mnemonic [
	^ #fptoui
]
