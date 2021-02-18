Class {
	#name : #LLVMPtrToIntInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMPtrToIntInst >> buildHandleWithBuilder: builder [
	handle := builder ptr: source validHandle toInt: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMPtrToIntInst >> mnemonic [
	^ #ptrtoint
]
