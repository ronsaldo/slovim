Class {
	#name : #LLVMIntToPtrConstantExpr,
	#superclass : #LLVMCastConstantExpr,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMIntToPtrConstantExpr >> mnemonic [
	^ #inttoptr
]
