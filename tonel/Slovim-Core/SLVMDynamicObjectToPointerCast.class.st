"
I am a casting instruction for unboxing pointers in dynamic objects.
"
Class {
	#name : #SLVMDynamicObjectToPointerCast,
	#superclass : #SLVMDynamicObjectCompositeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDynamicObjectToPointerCast class >> mnemonic [
	^ #dynobject2pointer
]

{ #category : #visiting }
SLVMDynamicObjectToPointerCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToPointerCast: self
]
