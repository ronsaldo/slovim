Class {
	#name : #SLVMDynamicObjectToBoolCast,
	#superclass : #SLVMDynamicObjectToNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDynamicObjectToBoolCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToBoolCast: self
]

{ #category : #printing }
SLVMDynamicObjectToBoolCast >> mnemonic [
	^ #dynobject2bool
]
