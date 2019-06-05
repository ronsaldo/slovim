"
I am a casting instruction for converting an integer into a float.
"
Class {
	#name : #SLVMIntToFloatCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMIntToFloatCast >> accept: aVisitor [
	^ aVisitor visitIntToFloatCast: self
]

{ #category : #testing }
SLVMIntToFloatCast >> isIntToFloatCast [
	^ true
]

{ #category : #printing }
SLVMIntToFloatCast >> mnemonic [
	^ #int2fp
]
