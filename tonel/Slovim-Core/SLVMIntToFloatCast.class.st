"
I am a casting instruction for converting an integer into a float.
"
Class {
	#name : #SLVMIntToFloatCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMIntToFloatCast class >> mnemonic [
	^ #int2fp
]

{ #category : #visiting }
SLVMIntToFloatCast >> accept: aVisitor [
	^ aVisitor visitIntToFloatCast: self
]

{ #category : #testing }
SLVMIntToFloatCast >> isIntToFloatCast [
	^ true
]
