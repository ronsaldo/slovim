Class {
	#name : #LLVMSExtInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMSExtInst >> mnemonic [
	^ #sext
]
