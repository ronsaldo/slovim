Class {
	#name : #SLVMDynamicObjectToStructureCast,
	#superclass : #SLVMDynamicObjectCompositeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDynamicObjectToStructureCast class >> mnemonic [
	^ #dynobject2struct
]

{ #category : #printing }
SLVMDynamicObjectToStructureCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToStructureCast: self
]
