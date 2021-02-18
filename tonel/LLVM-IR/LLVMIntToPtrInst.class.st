Class {
	#name : #LLVMIntToPtrInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMIntToPtrInst >> buildHandleWithBuilder: builder [
	handle := builder int: source validHandle toPtr: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMIntToPtrInst >> mnemonic [
	^ #inttoptr
]
