Class {
	#name : #SLVMConstantExpresionSubtract,
	#superclass : #SLVMConstantBinaryExpresion,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantExpresionSubtract >> accept: aVisitor [
	^ aVisitor visitConstantExpressionSubtract: self
]

{ #category : #printing }
SLVMConstantExpresionSubtract >> mnemonic [
	^ #constant_subtract
]
