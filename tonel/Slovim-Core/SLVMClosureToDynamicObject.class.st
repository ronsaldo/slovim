"
I am a casting instructio for converting a closure into a dynamic object.
"
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
