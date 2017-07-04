Class {
	#name : #SLVMFloatToDynamicObjectCast,
	#superclass : #SLVMDynamicObjectNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMFloatToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitFloatToDynamicObjectCast: self
]

{ #category : #visiting }
SLVMFloatToDynamicObjectCast >> mnemonic [
	^ #float2dynobject
]
