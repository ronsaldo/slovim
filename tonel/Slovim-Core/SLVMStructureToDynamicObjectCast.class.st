Class {
	#name : #SLVMStructureToDynamicObjectCast,
	#superclass : #SLVMDynamicObjectCompositeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMStructureToDynamicObjectCast class >> mnemonic [
	^ #struct2dynobject
]

{ #category : #visiting }
SLVMStructureToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitStructureToDynamicObjectCast: self
]
