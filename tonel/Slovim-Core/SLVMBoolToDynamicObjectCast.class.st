Class {
	#name : #SLVMBoolToDynamicObjectCast,
	#superclass : #SLVMNativeToDynamicObjectCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMBoolToDynamicObjectCast class >> mnemonic [
	^ #bool2dynobject
]

{ #category : #visiting }
SLVMBoolToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitBoolToDynamicObjectCast: self
]

{ #category : #testing }
SLVMBoolToDynamicObjectCast >> isBoolToDynamicObjectCast [
	^ true
]
