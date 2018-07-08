Class {
	#name : #LLVMBitCastConstantExpr,
	#superclass : #LLVMCastConstantExpr,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMBitCastConstantExpr >> mnemonic [
	^ #bitcast
]
