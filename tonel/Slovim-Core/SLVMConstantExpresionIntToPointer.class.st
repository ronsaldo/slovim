Class {
	#name : #SLVMConstantExpresionIntToPointer,
	#superclass : #SLVMConstantExpresionCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantExpresionIntToPointer class >> mnemonic [
	^ #constExprIntToPointer
]

{ #category : #visitor }
SLVMConstantExpresionIntToPointer >> accept: aVisitor [
	^ aVisitor visitConstantExpressionIntToPointer: self
]
