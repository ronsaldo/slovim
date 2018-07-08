Class {
	#name : #LLVMCastConstantExpr,
	#superclass : #LLVMConstantExpr,
	#instVars : [
		'source'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMCastConstantExpr >> printOn: aStream [
	aStream nextPutAll: self mnemonic; nextPutAll: '( '; print: source type; space; print: source; nextPutAll: ' to '; print: type; nextPutAll: ' )'.
]

{ #category : #accessing }
LLVMCastConstantExpr >> source [
	^ source
]

{ #category : #accessing }
LLVMCastConstantExpr >> source: anObject [
	source := anObject
]
