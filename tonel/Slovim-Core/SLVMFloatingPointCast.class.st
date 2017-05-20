Class {
	#name : #SLVMFloatingPointCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMFloatingPointCast >> accept: aVisitor [
	^ aVisitor visitFloatingPointCast: self
]

{ #category : #printing }
SLVMFloatingPointCast >> mnemonic [
	^ #fpcast
]
