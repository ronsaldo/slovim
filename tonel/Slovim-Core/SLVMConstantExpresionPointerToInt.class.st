Class {
	#name : #SLVMConstantExpresionPointerToInt,
	#superclass : #SLVMConstantExpresionCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantExpresionPointerToInt class >> mnemonic [
	^ #constExprPointerToInt
]

{ #category : #visitor }
SLVMConstantExpresionPointerToInt >> accept: aVisitor [
	^ aVisitor visitConstantExpressionPointerToInt: self
]
