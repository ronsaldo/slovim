Class {
	#name : #LLVMFPToUIInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMFPToUIInst >> buildHandleWithBuilder: builder [
	handle := builder fp: source validHandle toUI: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMFPToUIInst >> mnemonic [
	^ #fptoui
]
