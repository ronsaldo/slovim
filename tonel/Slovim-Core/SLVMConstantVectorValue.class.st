Class {
	#name : #SLVMConstantVectorValue,
	#superclass : #SLVMConstantAggregateValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantVectorValue class >> mnemonic [
	^ #constVector
]

{ #category : #visiting }
SLVMConstantVectorValue >> accept: aVisitor [
	^ aVisitor visitConstantVectorValue: self
]

{ #category : #testing }
SLVMConstantVectorValue >> isConstantVectorValue [
	^ true
]
