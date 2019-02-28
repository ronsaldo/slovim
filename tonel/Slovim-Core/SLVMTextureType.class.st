Class {
	#name : #SLVMTextureType,
	#superclass : #SLVMOpaqueType,
	#instVars : [
		'sampledType',
		'dimensions',
		'array',
		'depth',
		'multisample',
		'sampled',
		'format'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #comparing }
SLVMTextureType >> = other [
	^ (self isSameButDiffersInFormatWith: other) and: [
	format = other format ]
]

{ #category : #visitor }
SLVMTextureType >> accept: aVisitor [
	^ aVisitor visitTextureType: self
]

{ #category : #accessing }
SLVMTextureType >> array [
	^ array
]

{ #category : #accessing }
SLVMTextureType >> array: anObject [
	array := anObject
]

{ #category : #accessing }
SLVMTextureType >> depth [
	^ depth
]

{ #category : #accessing }
SLVMTextureType >> depth: anObject [
	depth := anObject
]

{ #category : #accessing }
SLVMTextureType >> dimensions [
	^ dimensions
]

{ #category : #accessing }
SLVMTextureType >> dimensions: anObject [
	dimensions := anObject
]

{ #category : #accessing }
SLVMTextureType >> format [
	^ format
]

{ #category : #accessing }
SLVMTextureType >> format: anObject [
	format := anObject
]

{ #category : #comparing }
SLVMTextureType >> internalHash [
	^ ((((((self class hash bitXor: dimensions hash)
			bitXor: sampledType hash)
			bitXor: array hash)
			bitXor: depth hash)
			bitXor: multisample hash)
			bitXor: sampled hash)
			bitXor: format hash
]

{ #category : #comparing }
SLVMTextureType >> isSameButDiffersInFormatWith: other [
	^ self class = other class and: [
	sampledType = other sampledType and: [
	dimensions = other dimensions and: [
	array = other array and: [depth = other depth and: [
	multisample = other multisample and: [
	sampled = other sampled]]]]]]
]

{ #category : #testing }
SLVMTextureType >> isTextureType [
	^ true
]

{ #category : #accessing }
SLVMTextureType >> multisample [
	^ multisample
]

{ #category : #accessing }
SLVMTextureType >> multisample: anObject [
	multisample := anObject
]

{ #category : #accessing }
SLVMTextureType >> requiredCoordinates [
	^ dimensions + (array asBit)
]

{ #category : #accessing }
SLVMTextureType >> sampled [
	^ sampled
]

{ #category : #accessing }
SLVMTextureType >> sampled: anObject [
	sampled := anObject
]

{ #category : #accessing }
SLVMTextureType >> sampledType [
	^ sampledType
]

{ #category : #accessing }
SLVMTextureType >> sampledType: anObject [
	sampledType := anObject
]
