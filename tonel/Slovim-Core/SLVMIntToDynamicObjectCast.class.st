Class {
	#name : #SLVMIntToDynamicObjectCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMIntToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitIntToDynamicObjectCast: self
]

{ #category : #visiting }
SLVMIntToDynamicObjectCast >> mnemonic [
	^ #int2dynobject
]
