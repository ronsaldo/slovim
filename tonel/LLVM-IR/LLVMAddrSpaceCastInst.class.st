Class {
	#name : #LLVMAddrSpaceCastInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #printing }
LLVMAddrSpaceCastInst >> mnemonic [
	^ #addrspacecast
]
