Class {
	#name : #LLVMDINamespace,
	#superclass : #LLVMDIScope,
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'as yet unclassified' }
LLVMDINamespace >> doConcretizeWithDIBuilder: builder [
	handle := builder createNamespaceIn: scope validHandle name: name len: name size exportSymbols: true
]

{ #category : #accessing }
LLVMDINamespace >> requiredProperties [
	^ #(scope)
]

{ #category : #accessing }
LLVMDINamespace >> specializedName [
	^ #DINamespace
]
