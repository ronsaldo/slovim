Class {
	#name : #SLVMZeroExtend,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMZeroExtend >> accept: aVisitor [
	^ aVisitor visitZeroExtend: self
]

{ #category : #printing }
SLVMZeroExtend >> mnemonic [
	^ #zext
]
