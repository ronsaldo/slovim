Class {
	#name : #LLVMSIToFPInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMSIToFPInst >> buildHandleWithBuilder: builder [
	handle := builder si: source validHandle toFP: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMSIToFPInst >> mnemonic [
	^ #sitofp
]
