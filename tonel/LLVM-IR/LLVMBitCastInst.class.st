Class {
	#name : #LLVMBitCastInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMBitCastInst >> mnemonic [
	^ #bitcast
]
