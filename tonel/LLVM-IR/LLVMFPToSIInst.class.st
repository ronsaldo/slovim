Class {
	#name : #LLVMFPToSIInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMFPToSIInst >> buildHandleWithBuilder: builder [
	handle := builder fp: source validHandle toSI: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMFPToSIInst >> mnemonic [
	^ #fptosi
]
