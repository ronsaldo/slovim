Class {
	#name : #LLVMSExtInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMSExtInst >> buildHandleWithBuilder: builder [
	handle := builder sext: source validHandle to: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMSExtInst >> mnemonic [
	^ #sext
]
