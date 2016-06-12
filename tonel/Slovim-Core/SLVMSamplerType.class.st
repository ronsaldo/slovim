Class {
	#name : #SLVMSamplerType,
	#superclass : #SLVMOpaqueType,
	#category : #'Slovim-Core-Type'
}

{ #category : #comparing }
SLVMSamplerType >> = other [
	^ self class = other class
]

{ #category : #visitor }
SLVMSamplerType >> accept: aVisitor [
	^ aVisitor visitSamplerType: self
]

{ #category : #comparing }
SLVMSamplerType >> hash [
	^ self class hash
]

{ #category : #testing }
SLVMSamplerType >> isSamplerType [
	^ true
]
