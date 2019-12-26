"
I am casting instruction for boxing integers in dynamic objects.
"
Class {
	#name : #SLVMIntToDynamicObjectCast,
	#superclass : #SLVMNativeToDynamicObjectCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMIntToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitIntToDynamicObjectCast: self
]

{ #category : #testing }
SLVMIntToDynamicObjectCast >> isIntToDynamicObjectCast [
	^ true
]

{ #category : #visiting }
SLVMIntToDynamicObjectCast >> mnemonic [
	^ #int2dynobject
]
