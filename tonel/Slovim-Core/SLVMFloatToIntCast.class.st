"
I am a casting instruction for converting a float by truncation into an integer.
"
Class {
	#name : #SLVMFloatToIntCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMFloatToIntCast class >> mnemonic [
	^ #fp2int
]

{ #category : #visiting }
SLVMFloatToIntCast >> accept: aVisitor [
	^ aVisitor visitFloatToIntCast: self
]

{ #category : #testing }
SLVMFloatToIntCast >> isFloatToIntCast [
	^ true
]
