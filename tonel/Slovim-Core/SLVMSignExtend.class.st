"
I am casting instruction for sign extending integers.
"
Class {
	#name : #SLVMSignExtend,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMSignExtend class >> mnemonic [
	^ #sext
]

{ #category : #visiting }
SLVMSignExtend >> accept: aVisitor [
	^ aVisitor visitSignExtend: self
]

{ #category : #testing }
SLVMSignExtend >> isSignExtend [
	^ true
]
