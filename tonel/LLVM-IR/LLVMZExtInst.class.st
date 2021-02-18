Class {
	#name : #LLVMZExtInst,
	#superclass : #LLVMCastInst,
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMZExtInst >> buildHandleWithBuilder: builder [
	handle := builder zext: source validHandle to: type validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMZExtInst >> mnemonic [
	^ #zext
]
