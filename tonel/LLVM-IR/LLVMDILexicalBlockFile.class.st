Class {
	#name : #LLVMDILexicalBlockFile,
	#superclass : #LLVMDILexicalBlockBase,
	#instVars : [
		'discriminator'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDILexicalBlockFile >> discriminator [
	^ discriminator
]

{ #category : #accessing }
LLVMDILexicalBlockFile >> discriminator: anObject [
	discriminator := anObject
]

{ #category : #initialization }
LLVMDILexicalBlockFile >> initialize [
	super initialize.
	discriminator := 0.
]

{ #category : #accessing }
LLVMDILexicalBlockFile >> specializedName [
	^ #DILexicalBlockFile
]

{ #category : #accessing }
LLVMDILexicalBlockFile >> specializedProperties [
	^ super specializedProperties , #(discriminator)
]
