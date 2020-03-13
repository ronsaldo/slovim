"
I am a casting instruction for boxing pointers in dynamic objects.
"
Class {
	#name : #SLVMPointerToDynamicObjectCast,
	#superclass : #SLVMDynamicObjectCompositeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMPointerToDynamicObjectCast class >> mnemonic [
	^ #pointer2dynobject
]

{ #category : #'as yet unclassified' }
SLVMPointerToDynamicObjectCast class >> source: source targetType: targetType typeObject: typeObject [
	^ self new source: source targetType: targetType typeObject: typeObject
]

{ #category : #visiting }
SLVMPointerToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitPointerToDynamicObjectCast: self
]
