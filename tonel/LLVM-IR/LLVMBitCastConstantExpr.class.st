Class {
	#name : #LLVMBitCastConstantExpr,
	#superclass : #LLVMCastConstantExpr,
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMBitCastConstantExpr >> buildHandle [
	handle := source validHandle constBitCastTo: type validHandle
]

{ #category : #printing }
LLVMBitCastConstantExpr >> mnemonic [
	^ #bitcast
]
