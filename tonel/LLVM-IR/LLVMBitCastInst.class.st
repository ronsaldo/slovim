Class {
	#name : #LLVMBitCastInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMBitCastInst >> buildHandleWithBuilder: builder [
	handle := builder bitCast: source validHandle to: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMBitCastInst >> mnemonic [
	^ #bitcast
]
