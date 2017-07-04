Class {
	#name : #SLVMDynamicObjectToFloatCast,
	#superclass : #SLVMDynamicObjectNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMDynamicObjectToFloatCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToFloatCast: self
]

{ #category : #printing }
SLVMDynamicObjectToFloatCast >> mnemonic [
	^ #dynobject2float
]
