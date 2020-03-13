Class {
	#name : #SLVMConstantUnionBlobValue,
	#superclass : #SLVMConstantArrayBlob,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantUnionBlobValue class >> mnemonic [
	^ #constUnion
]

{ #category : #visiting }
SLVMConstantUnionBlobValue >> accept: aVisitor [
	^ aVisitor visitConstantUnionBlobValue: self
]
