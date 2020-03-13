Class {
	#name : #SLVMDynamicObjectToCharCast,
	#superclass : #SLVMDynamicObjectToNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMDynamicObjectToCharCast class >> mnemonic [
	^ #dynobject2char
]

{ #category : #visitor }
SLVMDynamicObjectToCharCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToCharCast: self
]

{ #category : #visitor }
SLVMDynamicObjectToCharCast >> isDynamicObjectToCharCast [
	^ true
]
