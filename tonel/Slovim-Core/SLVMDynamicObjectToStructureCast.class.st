Class {
	#name : #SLVMDynamicObjectToStructureCast,
	#superclass : #SLVMDynamicObjectCompositeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDynamicObjectToStructureCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToStructureCast: self
]

{ #category : #printing }
SLVMDynamicObjectToStructureCast >> mnemonic [
	^ #dynobject2struct
]
