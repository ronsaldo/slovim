"
I am casting instruction for unboxing integers from dynamic objects.
"
Class {
	#name : #SLVMDynamicObjectToIntCast,
	#superclass : #SLVMDynamicObjectToNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDynamicObjectToIntCast class >> mnemonic [
	^ #dynobject2int
]

{ #category : #visiting }
SLVMDynamicObjectToIntCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToIntCast: self
]

{ #category : #testing }
SLVMDynamicObjectToIntCast >> isDynamicObjectToIntCast [
	^ true
]
