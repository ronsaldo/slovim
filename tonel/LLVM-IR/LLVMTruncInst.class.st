Class {
	#name : #LLVMTruncInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMTruncInst >> buildHandleWithBuilder: builder [
	handle := builder trunc: source validHandle to: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMTruncInst >> mnemonic [
	^ #trunc
]
