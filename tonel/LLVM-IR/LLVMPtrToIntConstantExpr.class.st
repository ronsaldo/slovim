Class {
	#name : #LLVMPtrToIntConstantExpr,
	#superclass : #LLVMCastConstantExpr,
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMPtrToIntConstantExpr >> buildHandle [
	handle := source validHandle constPtrToInt: type validHandle
]

{ #category : #printing }
LLVMPtrToIntConstantExpr >> mnemonic [
	^ #ptrtoint
]
