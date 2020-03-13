"
I am a casting instructio for converting a closure into a dynamic object.
"
Class {
	#name : #SLVMClosureToDynamicObject,
	#superclass : #SLVMDynamicObjectNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMClosureToDynamicObject class >> mnemonic [
	^ #closure2dynobject
]

{ #category : #visiting }
SLVMClosureToDynamicObject >> accept: aVisitor [
	^ aVisitor visitClosureToDynamicObject: self
]
