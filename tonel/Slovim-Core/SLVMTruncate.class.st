"
I am a casting instruction truncating integers,
"
Class {
	#name : #SLVMTruncate,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMTruncate >> accept: aVisitor [
	^ aVisitor visitTruncate: self
]

{ #category : #printing }
SLVMTruncate >> mnemonic [
	^ #truncate
]
