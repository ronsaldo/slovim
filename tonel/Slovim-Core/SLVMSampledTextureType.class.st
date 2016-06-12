Class {
	#name : #SLVMSampledTextureType,
	#superclass : #SLVMOpaqueType,
	#instVars : [
		'texture'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #comparing }
SLVMSampledTextureType >> = other [
	^ self class = other class and: [ texture = other texture ]
]

{ #category : #visitor }
SLVMSampledTextureType >> accept: aVisitor [
	^ aVisitor visitSampledTextureType: self
]

{ #category : #comparing }
SLVMSampledTextureType >> hash [
	^ self class hash bitXor: texture hash
]

{ #category : #testing }
SLVMSampledTextureType >> isSampledTextureType [
	^ true
]

{ #category : #accessing }
SLVMSampledTextureType >> texture [
	^ texture
]

{ #category : #accessing }
SLVMSampledTextureType >> texture: anObject [
	texture := anObject
]
