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

{ #category : #'as yet unclassified' }
LLVMDILexicalBlockFile >> doConcretizeWithDIBuilder: builder [
	handle := builder createLexicalBlockFileIn: scope validHandle file: file validHandle discriminator: (discriminator ifNil: [ 0 ])
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
