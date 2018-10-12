Class {
	#name : #LLVMPtrToIntInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMPtrToIntInst >> mnemonic [
	^ #ptrtoint
]
