Class {
	#name : #LLVMZExtInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMZExtInst >> mnemonic [
	^ #zext
]
