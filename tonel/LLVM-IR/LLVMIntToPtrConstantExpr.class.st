Class {
	#name : #LLVMIntToPtrConstantExpr,
	#superclass : #LLVMCastConstantExpr,
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMIntToPtrConstantExpr >> buildHandle [
	handle := source validHandle constIntToPtr: type validHandle
]

{ #category : #printing }
LLVMIntToPtrConstantExpr >> mnemonic [
	^ #inttoptr
]
