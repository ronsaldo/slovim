Class {
	#name : #SLVMVectorType,
	#superclass : #SLVMType,
	#instVars : [
		'baseType',
		'elements',
		'size',
		'alignment'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMVectorType class >> baseType: aBaseType elements: numElements [
	| alignmentMultiplier |
	alignmentMultiplier := numElements ~= 3 ifTrue: [ numElements ] ifFalse: [ 4 ].
	^ self baseType: aBaseType elements: numElements alignment: aBaseType alignment * alignmentMultiplier
]

{ #category : #construction }
SLVMVectorType class >> baseType: aBaseType elements: numElements alignment: anAlignment [
	^ self new
		baseType: aBaseType;
		elements: numElements;
		alignment: anAlignment;
		size: (aBaseType size * numElements alignedTo: anAlignment);
		yourself
]

{ #category : #comparing }
SLVMVectorType >> = other [
	^ self class == other class
		and: [
			baseType = other baseType and:
			[ elements = other elements and:
			[ alignment = other alignment ] ] ]
]

{ #category : #visitor }
SLVMVectorType >> accept: aVisitor [
	^ aVisitor visitVectorType: self
]

{ #category : #accessing }
SLVMVectorType >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMVectorType >> alignment: anObject [
	alignment := anObject
]

{ #category : #accessing }
SLVMVectorType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMVectorType >> baseType: anObject [
	baseType := anObject
]

{ #category : #accessing }
SLVMVectorType >> elements [
	^ elements
]

{ #category : #accessing }
SLVMVectorType >> elements: anObject [
	elements := anObject
]

{ #category : #comparing }
SLVMVectorType >> internalHash [
	^ ((self class hash bitXor: baseType hash) bitXor: elements hash) bitXor: alignment hash
]

{ #category : #testing }
SLVMVectorType >> isScalarType [
	^ false
]

{ #category : #testing }
SLVMVectorType >> isVectorType [
	^ true
]

{ #category : #accessing }
SLVMVectorType >> memberAt: constantValue [
	^ baseType
]

{ #category : #accessing }
SLVMVectorType >> name [
	^ self printString asSymbol
]

{ #category : #printing }
SLVMVectorType >> printOn: aStream [
	aStream print: baseType; print: elements
]

{ #category : #accessing }
SLVMVectorType >> registerClass [
	^ #vector
]

{ #category : #accessing }
SLVMVectorType >> size [
	^ size
]

{ #category : #accessing }
SLVMVectorType >> size: anObject [
	size := anObject
]

{ #category : #accessing }
SLVMVectorType >> typeOfMemberAt: index [
	^ self memberAt: index
]
