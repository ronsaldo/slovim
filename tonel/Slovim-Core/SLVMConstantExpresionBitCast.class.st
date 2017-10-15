Class {
	#name : #SLVMConstantExpresionBitCast,
	#superclass : #SLVMConstantExpresion,
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

{ #category : #accessing }
SLVMConstantExpresionBitCast >> value [
	^ parameters first
]

{ #category : #'as yet unclassified' }
SLVMConstantExpresionBitCast >> value: aValue targetType: aTargetType [
	self parameters: { aValue }.
	type := aTargetType
]
