Class {
	#name : #LLVMFPTruncInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMFPTruncInst >> buildHandleWithBuilder: builder [
	handle := builder fpTrunc: source validHandle to: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMFPTruncInst >> mnemonic [
	^ #fptrunc
]
