Class {
	#name : #SLVMIntegerType,
	#superclass : #SLVMPrimitiveType,
	#instVars : [
		'signed'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'as yet unclassified' }
SLVMIntegerType class >> name: aName size: aSize alignment: anAlignment signed: aBoolean [
	^ (self name: aName size: aSize alignment: anAlignment) signed: aBoolean; yourself
]

{ #category : #comparing }
SLVMIntegerType >> = other [
	^ super = other and: [ signed = other isSigned ]
]

{ #category : #visitor }
SLVMIntegerType >> accept: aVisitor [
	^ aVisitor visitIntegerType: self
]

{ #category : #converting }
SLVMIntegerType >> asFullSExpression [
	^ sname ifNil: [ sname := ((signed ifTrue: ['i'] ifFalse: ['u']) , (self size * 8) asString) asSymbol]
]

{ #category : #'as yet unclassified' }
SLVMIntegerType >> defaultConstant [
	^ SLVMConstant type: self value: 0
]

{ #category : #'as yet unclassified' }
SLVMIntegerType >> encodeConstant: value bigEndian: bigEndian intoByteStream: stream [
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

{ #category : #initialization }
SLVMIntegerType >> initialize [
	super initialize.
	signed := true.

]

{ #category : #comparing }
SLVMIntegerType >> internalHash [
	^ super internalHash bitXor: signed hash
]

{ #category : #testing }
SLVMIntegerType >> isIntegerType [
	^ true
]

{ #category : #testing }
SLVMIntegerType >> isSigned [
	^ signed
]

{ #category : #testing }
SLVMIntegerType >> isUnsigned [
	^ signed not
]

{ #category : #accessing }
SLVMIntegerType >> registerClass [
	^ #integer
]

{ #category : #'as yet unclassified' }
SLVMIntegerType >> selectorForLoadingFromPointer [
	^ ('_slvm_', (signed ifTrue: [ '' ] ifFalse: [ 'u' ]) , 'int' , (size * 8) asString , 'Value') asSymbol
]

{ #category : #accessing }
SLVMIntegerType >> signed: anObject [
	signed := anObject
]
