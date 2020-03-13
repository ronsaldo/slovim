Class {
	#name : #SLVMCharToDynamicObjectCast,
	#superclass : #SLVMNativeToDynamicObjectCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMCharToDynamicObjectCast class >> mnemonic [
	^ #char2dynobject
]

{ #category : #visitor }
SLVMCharToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitCharToDynamicObjectCast: self
]

{ #category : #visitor }
SLVMCharToDynamicObjectCast >> isCharToDynamicObjectCast [
	^ true
]
