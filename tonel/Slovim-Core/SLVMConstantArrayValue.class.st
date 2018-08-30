Class {
	#name : #SLVMConstantArrayValue,
	#superclass : #SLVMConstantAggregateValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantArrayValue >> accept: aVisitor [
	^ aVisitor visitConstantArrayValue: self
]

{ #category : #testing }
SLVMConstantArrayValue >> isConstantArrayValue [
	^ true
]

{ #category : #printing }
SLVMConstantArrayValue >> mnemonic [
	^ #constarray
]
