"
I am casting instruction for unboxing integers from dynamic objects.
"
Class {
	#name : #SLVMDynamicObjectToIntCast,
	#superclass : #SLVMDynamicObjectToNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMDynamicObjectToIntCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToIntCast: self
]

{ #category : #testing }
SLVMDynamicObjectToIntCast >> isDynamicObjectToIntCast [
	^ true
]

{ #category : #printing }
SLVMDynamicObjectToIntCast >> mnemonic [
	^ #dynobject2int
]
