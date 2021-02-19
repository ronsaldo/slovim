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

{ #category : #'as yet unclassified' }
LLVMDILexicalBlock >> doConcretizeWithDIBuilder: builder [
	handle := builder createLexicalBlockIn: scope validHandle file: (file ifNil: [LLVMMetadataRef null] ifNotNil: [file validHandle]) line: (line ifNil: [0]) column: (column ifNil: [0])
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
