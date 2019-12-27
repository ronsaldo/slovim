Class {
	#name : #LLVMDINamespace,
	#superclass : #LLVMDIScope,
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDINamespace >> requiredProperties [
	^ #(scope)
]

{ #category : #accessing }
LLVMDINamespace >> specializedName [
	^ #DINamespace
]
