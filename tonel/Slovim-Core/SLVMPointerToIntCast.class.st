Class {
	#name : #SLVMPointerToIntCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMPointerToIntCast >> accept: aVisitor [
	^ aVisitor visitPointerToIntCast:  self
]

{ #category : #testing }
SLVMPointerToIntCast >> isPointerToIntCast [
	^ true
]

{ #category : #visitor }
SLVMPointerToIntCast >> mnemonic [
	^ #ptr2int
]
