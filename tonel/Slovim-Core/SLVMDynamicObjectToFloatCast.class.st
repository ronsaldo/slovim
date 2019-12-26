"
I am casting instruction for unboxing floats from dynamic objects.
"
Class {
	#name : #SLVMDynamicObjectToFloatCast,
	#superclass : #SLVMDynamicObjectToNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMDynamicObjectToFloatCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToFloatCast: self
]

{ #category : #testing }
SLVMDynamicObjectToFloatCast >> isDynamicObjectToFloatCast [
	^ true
]

{ #category : #printing }
SLVMDynamicObjectToFloatCast >> mnemonic [
	^ #dynobject2float
]
