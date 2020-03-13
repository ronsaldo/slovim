Class {
	#name : #SLVMIntToPointerCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMIntToPointerCast class >> mnemonic [
	^ #int2ptr
]

{ #category : #visitor }
SLVMIntToPointerCast >> accept: aVisitor [
	^ aVisitor visitIntToPointerCast: self
]

{ #category : #testing }
SLVMIntToPointerCast >> isIntToPointerCast [
	^ true
]
