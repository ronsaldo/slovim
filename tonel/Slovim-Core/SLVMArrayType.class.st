Class {
	#name : #SLVMArrayType,
	#superclass : #SLVMType,
	#instVars : [
		'baseType',
		'elements'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMArrayType class >> baseType: baseType elements: elements [
	^ self new baseType: baseType; elements: elements; yourself
]

{ #category : #comparing }
SLVMArrayType >> = other [
	^ self class = other class and: [ baseType = other baseType and: [ elements = other elements ] ]
]

{ #category : #visitor }
SLVMArrayType >> accept: aVisitor [
	^ aVisitor visitArrayType: self
]

{ #category : #accessing }
SLVMArrayType >> alignment [
	^ baseType alignment
]

{ #category : #accessing }
SLVMArrayType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMArrayType >> baseType: anObject [
	baseType := anObject
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

{ #category : #'element accessing' }
SLVMArrayType >> strideWithIndex: index [
	^ index isConstantValue ifTrue: [ 0 ] ifFalse: [ baseType size ]
]

{ #category : #accessing }
SLVMArrayType >> typeOfMemberAt: index [
	^ self memberAt: index
]

{ #category : #writing }
SLVMArrayType >> write: value intoPointer: pointer [
	pointer _slvm_storeBytes: value count: self size
]
