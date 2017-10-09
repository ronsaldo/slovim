Class {
	#name : #SLVMPointerType,
	#superclass : #SLVMType,
	#instVars : [
		'size',
		'baseType',
		'storage'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMPointerType class >> size: size baseType: aBaseType storage: storage [
	^ self new size: size; baseType: aBaseType; storage: storage; yourself
]

{ #category : #comparing }
SLVMPointerType >> = other [
	^ self class == other class and: [ baseType = other baseType and: [ storage = other storage ] ] 
]

{ #category : #visitor }
SLVMPointerType >> accept: aVisitor [
	^ aVisitor visitPointerType: self
]

{ #category : #accessing }
SLVMPointerType >> alignment [
	^ size
]

{ #category : #accessing }
SLVMPointerType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMPointerType >> baseType: aType [
	self assert: aType isSlovimType.
	baseType := aType
]

{ #category : #accessing }
SLVMPointerType >> elementStrideDepth: depth [
	depth = 0 ifTrue: [ ^ size ].
	^ baseType size
]

{ #category : #'as yet unclassified' }
SLVMPointerType >> encodeConstant: value bigEndian: bigEndian intoByteStream: stream [
	| integerData |
	integerData := value.
	bigEndian ifTrue: [
		self halt.
	] ifFalse: [
		1 to: size do: [ :i |
			stream nextPut: (integerData bitAnd: 16rff).
			integerData := integerData >> 8
		] 
	]

]

{ #category : #comparing }
SLVMPointerType >> internalHash [
	^ (self class hash bitXor: (baseType hash)) bitXor: storage hash
]

{ #category : #testing }
SLVMPointerType >> isPointerType [
	^ true
]

{ #category : #testing }
SLVMPointerType >> isScalarType [
	^ true
]

{ #category : #'element accessing' }
SLVMPointerType >> offsetWithIndex: index [
	^ index isConstantValue ifTrue: [ baseType size * index value ] ifFalse: [ 0 ]
]

{ #category : #printing }
SLVMPointerType >> printOn: aStream [
	aStream nextPutAll: baseType shortName;
		nextPutAll: '* '; print: storage
]

{ #category : #accessing }
SLVMPointerType >> registerClass [
	^ #integer
]

{ #category : #'as yet unclassified' }
SLVMPointerType >> selectorForLoadingFromPointer [
	^ #pointerValue
]

{ #category : #'as yet unclassified' }
SLVMPointerType >> selectorForStoringIntoPointer [
	^ #pointerValue:
]

{ #category : #accessing }
SLVMPointerType >> size [
	^ size
]

{ #category : #accessing }
SLVMPointerType >> size: anObject [
	size := anObject
]

{ #category : #accessing }
SLVMPointerType >> storage [
	^ storage
]

{ #category : #accessing }
SLVMPointerType >> storage: aSymbol [
	self assert: aSymbol isSymbol.
	storage := aSymbol
]

{ #category : #'element accessing' }
SLVMPointerType >> strideWithIndex: index [
	^ index isConstantValue ifTrue: [ 0 ] ifFalse: [ baseType size ]
]

{ #category : #accessing }
SLVMPointerType >> typeOfMemberAt: index [
	^ baseType
]
