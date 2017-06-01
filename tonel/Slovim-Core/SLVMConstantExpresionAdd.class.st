Class {
	#name : #SLVMConstantExpresionAdd,
	#superclass : #SLVMConstantBinaryExpresion,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantExpresionAdd >> accept: aVisitor [
	^ aVisitor visitConstantExpressionAdd: self
]

{ #category : #printing }
SLVMConstantExpresionAdd >> mnemonic [
	^ #constant_add
]
