Class {
	#name : #SLVMDynamicObjectToIntCast,
	#superclass : #SLVMDynamicObjectNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMDynamicObjectToIntCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToIntCast: self
]

{ #category : #printing }
SLVMDynamicObjectToIntCast >> mnemonic [
	^ #dynobject2int
]