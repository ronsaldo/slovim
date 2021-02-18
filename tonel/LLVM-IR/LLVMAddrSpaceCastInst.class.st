Class {
	#name : #LLVMAddrSpaceCastInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMAddrSpaceCastInst >> buildHandleWithBuilder: builder [
	handle := builder addrSpaceCast: source validHandle to: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMAddrSpaceCastInst >> mnemonic [
	^ #addrspacecast
]
