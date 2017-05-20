Class {
	#name : #SLVMFloatToIntCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMFloatToIntCast >> accept: aVisitor [
	^ aVisitor visitFloatToIntCast: self
]

{ #category : #printing }
SLVMFloatToIntCast >> mnemonic [
	^ #fp2int
]
