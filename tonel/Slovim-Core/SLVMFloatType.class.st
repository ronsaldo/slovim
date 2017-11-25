Class {
	#name : #SLVMFloatType,
	#superclass : #SLVMPrimitiveType,
	#category : #'Slovim-Core-Type'
}

{ #category : #visitor }
SLVMFloatType >> accept: aVisitor [
	^ aVisitor visitFloatType: self
]

{ #category : #'as yet unclassified' }
SLVMFloatType >> encodeConstant: value bigEndian: bigEndian intoByteStream: stream [
	| integerData |
	size = 4 ifTrue: [
		integerData := value asIEEE32BitWord.
	].
	size = 8 ifTrue: [ 
		integerData := ((value basicAt: 1) << 32) | (value basicAt: 2).
	].

	integerData ifNil: [	self error: 'Not yet supported.' ].
		
	bigEndian ifTrue: [
		self halt.
	] ifFalse: [
		1 to: size do: [ :i |
			stream nextPut: (integerData bitAnd: 16rff).
			integerData := integerData >> 8
		] 
	]
	
]

{ #category : #testing }
SLVMFloatType >> isFloatType [
	^ true
]

{ #category : #accessing }
SLVMFloatType >> registerClass [
	^ #float
]

{ #category : #'as yet unclassified' }
SLVMFloatType >> selectorForLoadingFromPointer [
	^ ('_slvm_float' , (size * 8) asString , 'Value') asSymbol
]
