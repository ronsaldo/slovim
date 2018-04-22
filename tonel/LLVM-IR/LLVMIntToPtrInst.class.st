Class {
	#name : #LLVMIntToPtrInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMIntToPtrInst >> mnemonic [
	^ #inttoptr
]
