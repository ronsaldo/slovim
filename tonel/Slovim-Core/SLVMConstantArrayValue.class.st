Class {
	#name : #SLVMConstantArrayValue,
	#superclass : #SLVMConstantAggregateValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantArrayValue class >> mnemonic [
	^ #constArray
]

{ #category : #visiting }
SLVMConstantArrayValue >> accept: aVisitor [
	^ aVisitor visitConstantArrayValue: self
]

{ #category : #testing }
SLVMConstantArrayValue >> isConstantArrayValue [
	^ true
]
