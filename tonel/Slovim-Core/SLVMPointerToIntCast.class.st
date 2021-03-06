Class {
	#name : #SLVMPointerToIntCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMPointerToIntCast class >> mnemonic [
	^ #ptr2int
]

{ #category : #visitor }
SLVMPointerToIntCast >> accept: aVisitor [
	^ aVisitor visitPointerToIntCast:  self
]

{ #category : #testing }
SLVMPointerToIntCast >> isPointerToIntCast [
	^ true
]
