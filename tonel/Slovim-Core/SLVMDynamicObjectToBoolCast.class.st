Class {
	#name : #SLVMDynamicObjectToBoolCast,
	#superclass : #SLVMDynamicObjectToNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDynamicObjectToBoolCast class >> mnemonic [
	^ #dynobject2bool
]

{ #category : #printing }
SLVMDynamicObjectToBoolCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToBoolCast: self
]

{ #category : #testing }
SLVMDynamicObjectToBoolCast >> isDynamicObjectToBoolCast [
	^ true
]
