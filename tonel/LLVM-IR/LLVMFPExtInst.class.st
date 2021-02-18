Class {
	#name : #LLVMFPExtInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMFPExtInst >> buildHandleWithBuilder: builder [
	handle := builder fpExt: source validHandle to: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMFPExtInst >> mnemonic [
	^ #fpext
]
