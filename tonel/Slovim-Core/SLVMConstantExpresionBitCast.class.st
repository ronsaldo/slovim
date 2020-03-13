Class {
	#name : #SLVMConstantExpresionBitCast,
	#superclass : #SLVMConstantExpresionCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantExpresionBitCast class >> mnemonic [
	^ #constExprBitcast
]

{ #category : #visiting }
SLVMConstantExpresionBitCast >> accept: aVisitor [
	^ aVisitor visitConstantExpressionBitCast: self
]

{ #category : #testing }
SLVMConstantExpresionBitCast >> isConstantExpressionBitCast [
	^ true
]
