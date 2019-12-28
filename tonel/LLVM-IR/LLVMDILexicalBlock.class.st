Class {
	#name : #LLVMDILexicalBlock,
	#superclass : #LLVMDILexicalBlockBase,
	#instVars : [
		'line',
		'column'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDILexicalBlock >> column [
	^ column
]

{ #category : #accessing }
LLVMDILexicalBlock >> column: anObject [
	column := anObject
]

{ #category : #accessing }
LLVMDILexicalBlock >> line [
	^ line
]

{ #category : #accessing }
LLVMDILexicalBlock >> line: anObject [
	line := anObject
]

{ #category : #accessing }
LLVMDILexicalBlock >> specializedName [
	^ #DILexicalBlock
]

{ #category : #accessing }
LLVMDILexicalBlock >> specializedProperties [
	^ super specializedProperties , #(line column)
]
