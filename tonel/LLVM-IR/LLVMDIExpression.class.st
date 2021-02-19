Class {
	#name : #LLVMDIExpression,
	#superclass : #LLVMMDNode,
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'as yet unclassified' }
LLVMDIExpression >> doConcretizeWithDIBuilder: builder [
	handle := builder createEmptyDIExpression
]

{ #category : #accessing }
LLVMDIExpression >> specializedName [
	^ #DIExpression
]

{ #category : #accessing }
LLVMDIExpression >> specializedProperties [
	^ #()
]
