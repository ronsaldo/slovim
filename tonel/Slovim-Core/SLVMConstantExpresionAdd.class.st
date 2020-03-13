Class {
	#name : #SLVMConstantExpresionAdd,
	#superclass : #SLVMConstantBinaryExpresion,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantExpresionAdd class >> mnemonic [
	^ #constExprAdd
]

{ #category : #visiting }
SLVMConstantExpresionAdd >> accept: aVisitor [
	^ aVisitor visitConstantExpressionAdd: self
]
