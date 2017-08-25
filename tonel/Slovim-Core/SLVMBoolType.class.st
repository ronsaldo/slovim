Class {
	#name : #SLVMBoolType,
	#superclass : #SLVMPrimitiveType,
	#category : #'Slovim-Core-Type'
}

{ #category : #visitor }
SLVMBoolType >> accept: aVisitor [
	^ aVisitor visitBoolType: self
]

{ #category : #'constant encoding' }
SLVMBoolType >> encodeConstant: value bigEndian: bigEndian intoByteStream: stream [
	value ifFalse: [ 
		1 to: size do: [ :i |
			stream nextPut: 0.
		].
		^ self
	].

	bigEndian ifTrue: [
		self halt.
	] ifFalse: [
		1 to: size do: [ :i |
			stream nextPut: (i = 1 ifTrue: [ 1 ] ifFalse: [0]).
		] 
	]

]

{ #category : #initialization }
SLVMBoolType >> initialize [
	super initialize.
	self name: #bool;
		size: 4.
]

{ #category : #testing }
SLVMBoolType >> isBooleanType [
	^ true
]

{ #category : #accessing }
SLVMBoolType >> registerClass [
	^ #integer
]
