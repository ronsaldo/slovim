Class {
	#name : #SLVMCast,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMCast >> accept: aVisitor [
	^ aVisitor visitCast: self
]
