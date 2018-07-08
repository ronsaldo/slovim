Class {
	#name : #SLVMConstantExpresionBitCast,
	#superclass : #SLVMConstantExpresionCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantExpresionBitCast >> accept: aVisitor [
	^ aVisitor visitConstantExpressionBitCast: self
]

{ #category : #testing }
SLVMConstantExpresionBitCast >> isConstantExpressionBitCast [
	^ true
]

{ #category : #printing }
SLVMConstantExpresionBitCast >> mnemonic [
	^ #const_bitcast
]
