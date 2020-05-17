Class {
	#name : #SLVMVectorType,
	#superclass : #SLVMType,
	#instVars : [
		'baseType',
		'elements',
		'size',
		'alignment',
		'fullSExpression'
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
		size: aBaseType size * numElements;
		yourself
]

{ #category : #printing }
SLVMVectorType class >> mnemonic [
	^ #vector
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

{ #category : #converting }
SLVMVectorType >> asFullSExpression [
	^ fullSExpression ifNil: [ fullSExpression := { #vector . baseType asSExpression . elements } ]
]

{ #category : #accessing }
SLVMVectorType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMVectorType >> baseType: anObject [
	baseType := anObject
]

{ #category : #'as yet unclassified' }
SLVMVectorType >> decodeFromFullSExpression: encodedType context: decodingContext [
	self assert: encodedType size = 3.
	baseType := decodingContext decodeSExpressionType: encodedType second.
	elements := encodedType third.
	size := baseType size * elements.
	alignment := baseType alignment * (elements ~= 3 ifTrue: [ elements ] ifFalse: [ 4 ]).
]

{ #category : #'as yet unclassified' }
SLVMVectorType >> defaultFullConstant [
	^ SLVMConstant vector: self elements: ((1 to: elements) collect: [:each | baseType defaultFullConstant])
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
SLVMVectorType >> isBooleanVectorType [
	^ baseType isBooleanType
]

{ #category : #testing }
SLVMVectorType >> isFloatVectorType [
	^ baseType isFloatType
]

{ #category : #testing }
SLVMVectorType >> isIntegerVectorType [
	^ baseType isIntegerType
]

{ #category : #accessing }
SLVMVectorType >> isMemberInBoundsAt: index [
	^ index isConstantValue and: [ index value < elements ]
]

{ #category : #testing }
SLVMVectorType >> isScalarType [
	^ false
]

{ #category : #testing }
SLVMVectorType >> isSigned [
	^ baseType isSigned
]

{ #category : #testing }
SLVMVectorType >> isUnsigned [
	^ baseType isUnsigned
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
