Class {
	#name : #SLVMStructureToDynamicObjectCast,
	#superclass : #SLVMDynamicObjectCompositeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMStructureToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitStructureToDynamicObjectCast: self
]

{ #category : #visiting }
SLVMStructureToDynamicObjectCast >> mnemonic [
	^ #struct2dynobject
]
