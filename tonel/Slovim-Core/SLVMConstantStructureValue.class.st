Class {
	#name : #SLVMConstantStructureValue,
	#superclass : #SLVMConstantAggregateValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantStructureValue class >> mnemonic [
	^ #constStruct
]

{ #category : #visiting }
SLVMConstantStructureValue >> accept: aVisitor [
	^ aVisitor visitConstantStructureValue: self
]

{ #category : #testing }
SLVMConstantStructureValue >> isConstantStructureValue [
	^ true
]
