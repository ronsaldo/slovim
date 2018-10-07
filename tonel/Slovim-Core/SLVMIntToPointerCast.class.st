Class {
	#name : #SLVMIntToPointerCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMIntToPointerCast >> accept: aVisitor [
	^ aVisitor visitIntToPointerCast: self
]

{ #category : #visitor }
SLVMIntToPointerCast >> mnemonic [
	^ #int2ptr
]
