"
I am casting instruction zero extending integers.
"
Class {
	#name : #SLVMZeroExtend,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMZeroExtend class >> mnemonic [
	^ #zext
]

{ #category : #visiting }
SLVMZeroExtend >> accept: aVisitor [
	^ aVisitor visitZeroExtend: self
]

{ #category : #testing }
SLVMZeroExtend >> isZeroExtend [
	^ true
]
