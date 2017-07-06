Class {
	#name : #SLVMSignExtend,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMSignExtend >> accept: aVisitor [
	^ aVisitor visitSignExtend: self
]

{ #category : #printing }
SLVMSignExtend >> mnemonic [
	^ #sext
]