"
I am a casting instruction truncating integers,
"
Class {
	#name : #SLVMTruncate,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMTruncate class >> mnemonic [
	^ #truncate
]

{ #category : #visiting }
SLVMTruncate >> accept: aVisitor [
	^ aVisitor visitTruncate: self
]

{ #category : #testing }
SLVMTruncate >> isTruncate [
	^ true
]
