Class {
	#name : #SLVMDynamicObjectToCharCast,
	#superclass : #SLVMDynamicObjectToNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMDynamicObjectToCharCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToCharCast: self
]

{ #category : #visitor }
SLVMDynamicObjectToCharCast >> isDynamicObjectToCharCast [
	^ true
]

{ #category : #visitor }
SLVMDynamicObjectToCharCast >> mnemonic [
	^ #dynobject2char
]
