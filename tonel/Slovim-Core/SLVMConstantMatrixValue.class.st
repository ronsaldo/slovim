Class {
	#name : #SLVMConstantMatrixValue,
	#superclass : #SLVMConstantAggregateValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantMatrixValue >> accept: aVisitor [
	^ aVisitor visitConstantMatrixValue: self
]

{ #category : #testing }
SLVMConstantMatrixValue >> isConstantMatrixValue [
	^ true
]
