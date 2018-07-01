Class {
	#name : #SLVMConstantStructureValue,
	#superclass : #SLVMConstantAggregateValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantStructureValue >> accept: aVisitor [
	^ aVisitor visitConstantStructureValue: self
]

{ #category : #testing }
SLVMConstantStructureValue >> isConstantStructureValue [
	^ true
]
