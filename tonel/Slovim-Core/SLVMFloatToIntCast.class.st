"
I am a casting instruction for converting a float by truncation into an integer.
"
Class {
	#name : #SLVMFloatToIntCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMFloatToIntCast >> accept: aVisitor [
	^ aVisitor visitFloatToIntCast: self
]

{ #category : #testing }
SLVMFloatToIntCast >> isFloatToIntCast [
	^ true
]

{ #category : #printing }
SLVMFloatToIntCast >> mnemonic [
	^ #fp2int
]
