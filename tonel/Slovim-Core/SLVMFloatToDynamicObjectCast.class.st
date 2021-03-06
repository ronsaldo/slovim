"
I am casting instruction for boxing floats in dynamic objects.
"
Class {
	#name : #SLVMFloatToDynamicObjectCast,
	#superclass : #SLVMNativeToDynamicObjectCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMFloatToDynamicObjectCast class >> mnemonic [
	^ #float2dynobject
]

{ #category : #visiting }
SLVMFloatToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitFloatToDynamicObjectCast: self
]

{ #category : #testing }
SLVMFloatToDynamicObjectCast >> isFloatToDynamicObjectCast [
	^ true
]
