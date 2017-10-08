"
I am a casting instruction for boxing pointers in dynamic objects.
"
Class {
	#name : #SLVMPointerToDynamicObjectCast,
	#superclass : #SLVMDynamicObjectPointerCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMPointerToDynamicObjectCast class >> source: source targetType: targetType typeObject: typeObject [
	^ self new source: source targetType: targetType typeObject: typeObject
]

{ #category : #visiting }
SLVMPointerToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitPointerToDynamicObjectCast: self
]

{ #category : #printing }
SLVMPointerToDynamicObjectCast >> mnemonic [
	^ #pointer2dynobject
]
