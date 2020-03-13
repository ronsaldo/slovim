Class {
	#name : #SLVMConstantExpresionSubtract,
	#superclass : #SLVMConstantBinaryExpresion,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantExpresionSubtract class >> mnemonic [
	^ #constExprSub
]

{ #category : #visiting }
SLVMConstantExpresionSubtract >> accept: aVisitor [
	^ aVisitor visitConstantExpressionSubtract: self
]
