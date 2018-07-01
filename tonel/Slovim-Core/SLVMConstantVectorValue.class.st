Class {
	#name : #SLVMConstantVectorValue,
	#superclass : #SLVMConstantAggregateValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantVectorValue >> accept: aVisitor [
	^ aVisitor visitConstantVectorValue: self
]

{ #category : #testing }
SLVMConstantVectorValue >> isConstantVectorValue [
	^ true
]
