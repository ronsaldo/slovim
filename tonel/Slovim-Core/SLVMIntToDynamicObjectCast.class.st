Class {
	#name : #SLVMIntToDynamicObjectCast,
	#superclass : #SLVMDynamicObjectNativeCast,
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
