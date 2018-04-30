Class {
	#name : #LLVMDIGlobalVariable,
	#superclass : #LLVMDIVariable,
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIGlobalVariable >> specializedName [
	^ #DIGlobalVariable
]
