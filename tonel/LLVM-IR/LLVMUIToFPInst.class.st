Class {
	#name : #LLVMUIToFPInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMUIToFPInst >> buildHandleWithBuilder: builder [
	handle := builder ui: source validHandle toFP: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMUIToFPInst >> mnemonic [
	^ #uitofp
]
