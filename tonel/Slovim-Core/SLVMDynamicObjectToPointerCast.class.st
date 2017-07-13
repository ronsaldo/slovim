Class {
	#name : #SLVMDynamicObjectToPointerCast,
	#superclass : #SLVMDynamicObjectPointerCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMDynamicObjectToPointerCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToPointerCast: self
]

{ #category : #printing }
SLVMDynamicObjectToPointerCast >> mnemonic [
	^ #dynobject2pointer
]
