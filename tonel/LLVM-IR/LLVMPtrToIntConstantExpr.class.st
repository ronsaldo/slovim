Class {
	#name : #LLVMPtrToIntConstantExpr,
	#superclass : #LLVMCastConstantExpr,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMPtrToIntConstantExpr >> mnemonic [
	^ #ptrtoint
]
