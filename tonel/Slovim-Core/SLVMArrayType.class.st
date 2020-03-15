Class {
	#name : #SLVMArrayType,
	#superclass : #SLVMType,
	#instVars : [
		'baseType',
		'elements',
		'fullSExpression'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMArrayType class >> baseType: baseType elements: elements [
	^ self new baseType: baseType; elements: elements; yourself
]

{ #category : #printing }
SLVMArrayType class >> mnemonic [
	^ #array
]

{ #category : #comparing }
SLVMArrayType >> = other [
	^ self class = other class and: [ baseType = other baseType and: [ elements = other elements ] ]
]

{ #category : #visitor }
SLVMArrayType >> accept: aVisitor [
	^ aVisitor visitArrayType: self
]

{ #category : #adding }
SLVMArrayType >> addCount: extraElements [
	extraElements = 0 ifTrue: [ ^ self ].
	^ self class baseType: baseType elements: elements + extraElements
]

{ #category : #accessing }
SLVMArrayType >> alignment [
	^ baseType alignment
]

{ #category : #converting }
SLVMArrayType >> asFullSExpression [
	^ fullSExpression ifNil: [ fullSExpression := { self mnemonic . baseType asSExpression . elements } ]
]

{ #category : #accessing }
SLVMArrayType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMArrayType >> baseType: anObject [
	baseType := anObject
]

{ #category : #'as yet unclassified' }
SLVMArrayType >> decodeFromFullSExpression: encodedType context: decodingContext [
	self assert: encodedType size = 3.
	baseType := decodingContext decodeSExpressionType: encodedType second.
	elements := encodedType third.
]

{ #category : #'as yet unclassified' }
SLVMArrayType >> defaultConstant [
	^ SLVMConstant zeroInitializer: self
]

{ #category : #'as yet unclassified' }
SLVMArrayType >> defaultFullConstant [
	^ SLVMConstant array: self slots: ((1 to: (elements ifNil: [0])) collect: [:each | each defaultFullConstant])
]

{ #category : #accessing }
SLVMArrayType >> elements [
	^ elements
]

{ #category : #accessing }
SLVMArrayType >> elements: anObject [
	elements := anObject
]

{ #category : #comparing }
SLVMArrayType >> internalHash [	
	^ (self class hash bitXor: baseType hash) bitXor: elements hash
]

{ #category : #testing }
SLVMArrayType >> isAggregateType [
	^ true
]

{ #category : #testing }
SLVMArrayType >> isArrayType [
	^ true
]

{ #category : #testing }
SLVMArrayType >> isBounded [
	^ elements isNotNil
]

{ #category : #accessing }
SLVMArrayType >> isMemberInBoundsAt: index [
	^ index isConstantValue and: [ index value < self validElements ]
]

{ #category : #accessing }
SLVMArrayType >> memberAt: constantValue [
	^ baseType
]

{ #category : #accessing }
SLVMArrayType >> name [
	^ self printString
]

{ #category : #'element accessing' }
SLVMArrayType >> offsetWithIndex: index [
	^ index isConstantValue ifTrue: [ index value * baseType size ] ifFalse: [ 0 ]
]

{ #category : #printing }
SLVMArrayType >> printOn: aStream [
	aStream print: baseType; nextPut: $[.
	elements ifNotNil: [ aStream print: elements ].
	aStream nextPut: $]
]

{ #category : #writing }
SLVMArrayType >> readFromPointer: pointer [
	| result |
	self isBounded ifFalse: [ ^ #() ].
	result := SLVMNativeArray for: baseType new: elements.
	pointer _slvm_loadBytesInto: result rawData count: self size.
	^ result
]

{ #category : #accessing }
SLVMArrayType >> size [
	^ self isBounded ifTrue: [ baseType size * elements ] ifFalse: [ 0 ]
]

{ #category : #'as yet unclassified' }
SLVMArrayType >> storeAndPopValueIntoPointerWith: irBuilder [
	^ irBuilder
		pushLiteral: self;
		send: #_slvm_storeArrayValueInto:type:;
		popTop
	
]

{ #category : #'as yet unclassified' }
SLVMArrayType >> storeAndPopValueWith: irBuilder [
	^ irBuilder
		pushLiteral: self;
		send: #_slvm_storeArrayValue:type:;
		popTop
	
]

{ #category : #'as yet unclassified' }
SLVMArrayType >> storeValueIntoPointerWith: irBuilder [
	^ irBuilder
		pushLiteral: self;
		send: #_slvm_storeArrayValueInto:type:
	
]

{ #category : #'as yet unclassified' }
SLVMArrayType >> storeValueWith: irBuilder [
	^ irBuilder
		pushLiteral: self;
		send: #_slvm_storeArrayValue:type:
	
]

{ #category : #'element accessing' }
SLVMArrayType >> strideWithIndex: index [
	^ index isConstantValue ifTrue: [ 0 ] ifFalse: [ baseType size ]
]

{ #category : #accessing }
SLVMArrayType >> typeOfMemberAt: index [
	^ self memberAt: index
]

{ #category : #'as yet unclassified' }
SLVMArrayType >> validElements [
	^ elements ifNil: [ 0 ]
]

{ #category : #writing }
SLVMArrayType >> write: value intoPointer: pointer [
	pointer _slvm_storeBytes: value count: self size
]
