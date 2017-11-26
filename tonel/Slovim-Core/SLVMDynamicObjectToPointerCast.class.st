"
I am a casting instruction for unboxing pointers in dynamic objects.
"
Class {
	#name : #SLVMDynamicObjectToPointerCast,
	#superclass : #SLVMDynamicObjectCompositeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMDynamicObjectToPointerCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToPointerCast: self
]

{ #category : #printing }
SLVMDynamicObjectToPointerCast >> mnemonic [
	^ #dynobject2pointer
]
