Class {
	#name : #SLVMClosureToDynamicObject,
	#superclass : #SLVMDynamicObjectNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMClosureToDynamicObject >> accept: aVisitor [
	^ aVisitor visitClosureToDynamicObject: self
]

{ #category : #printing }
SLVMClosureToDynamicObject >> mnemonic [
	^ #closure2dynobject
]
