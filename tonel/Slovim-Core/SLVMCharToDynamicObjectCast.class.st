Class {
	#name : #SLVMCharToDynamicObjectCast,
	#superclass : #SLVMNativeToDynamicObjectCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMCharToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitCharToDynamicObjectCast: self
]

{ #category : #visitor }
SLVMCharToDynamicObjectCast >> isCharToDynamicObjectCast [
	^ true
]

{ #category : #visitor }
SLVMCharToDynamicObjectCast >> mnemonic [
	^ #char2dynobject
]
