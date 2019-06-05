"
I am casting instruction for converting between floats of different sizes.
"
Class {
	#name : #SLVMFloatingPointCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMFloatingPointCast >> accept: aVisitor [
	^ aVisitor visitFloatingPointCast: self
]

{ #category : #testing }
SLVMFloatingPointCast >> isFloatingPointCast [
	^ true
]

{ #category : #printing }
SLVMFloatingPointCast >> mnemonic [
	^ #fpcast
]
