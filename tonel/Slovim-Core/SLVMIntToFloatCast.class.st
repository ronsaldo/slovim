Class {
	#name : #SLVMIntToFloatCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMIntToFloatCast >> accept: aVisitor [
	^ aVisitor visitIntToFloatCast: self
]

{ #category : #printing }
SLVMIntToFloatCast >> mnemonic [
	^ #int2fp
]
