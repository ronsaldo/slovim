Class {
	#name : #SLVMSampledTextureType,
	#superclass : #SLVMOpaqueType,
	#instVars : [
		'texture',
		'fullSExpression'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #printing }
SLVMSampledTextureType class >> mnemonic [
	^ #sampledTexture
]

{ #category : #comparing }
SLVMSampledTextureType >> = other [
	^ self class = other class and: [ texture = other texture ]
]

{ #category : #visitor }
SLVMSampledTextureType >> accept: aVisitor [
	^ aVisitor visitSampledTextureType: self
]

{ #category : #converting }
SLVMSampledTextureType >> asFullSExpression [
	^ fullSExpression ifNil: [ fullSExpression := { self mnemonic . texture asSExpression } ]
]

{ #category : #comparing }
SLVMSampledTextureType >> internalHash [
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
