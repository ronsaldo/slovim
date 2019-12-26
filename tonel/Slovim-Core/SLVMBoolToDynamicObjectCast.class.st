Class {
	#name : #SLVMBoolToDynamicObjectCast,
	#superclass : #SLVMNativeToDynamicObjectCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMBoolToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitBoolToDynamicObjectCast: self
]

{ #category : #testing }
SLVMBoolToDynamicObjectCast >> isBoolToDynamicObjectCast [
	^ true
]

{ #category : #printing }
SLVMBoolToDynamicObjectCast >> mnemonic [
	^ #bool2dynobject
]
