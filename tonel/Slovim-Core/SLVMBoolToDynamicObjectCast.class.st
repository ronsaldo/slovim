Class {
	#name : #SLVMBoolToDynamicObjectCast,
	#superclass : #SLVMNativeToDynamicObjectCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMBoolToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitBoolToDynamicObjectCast: self
]

{ #category : #printing }
SLVMBoolToDynamicObjectCast >> mnemonic [
	^ #bool2dynobject
]
