Class {
	#name : #SLVMConstantUnionBlobValue,
	#superclass : #SLVMConstantArrayBlob,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantUnionBlobValue >> accept: aVisitor [
	^ aVisitor visitConstantUnionBlobValue: self
]

{ #category : #printing }
SLVMConstantUnionBlobValue >> mnemonic [
	^ #constunion
]
