Class {
	#name : #SLVMVoidType,
	#superclass : #SLVMOpaqueType,
	#category : #'Slovim-Core-Type'
}

{ #category : #comparing }
SLVMVoidType >> = other [
	^ self class == other class
]

{ #category : #visitor }
SLVMVoidType >> accept: aVisitor [
	^ aVisitor visitVoidType: self
]

{ #category : #comparing }
SLVMVoidType >> internalHash [
	^ self class hash
]

{ #category : #testing }
SLVMVoidType >> isVoidType [
	^ true
]

{ #category : #printing }
SLVMVoidType >> printOn: aStream [
	aStream nextPutAll: 'void'
]
