Class {
	#name : #SLVMMessagePackEncoder,
	#superclass : #Object,
	#instVars : [
		'outputStream'
	],
	#pools : [
		'SLVMMessagePackConstants'
	],
	#category : #'Slovim-MessagePack-Encoder'
}

{ #category : #encoding }
SLVMMessagePackEncoder class >> encodeObject: anObject [
	^ ByteArray streamContents: [ :out |
		self encodeObject: anObject into: out
	]
]

{ #category : #encoding }
SLVMMessagePackEncoder class >> encodeObject: anObject into: outputStream [
	^ self new
		outputStream: outputStream;
		encodeObject: anObject;
		yourself
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeArray: aSequenceableCollection [
	self encodeArraySize: aSequenceableCollection size.
	aSequenceableCollection do: [:each |
		self encodeObject: each
	].
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeArraySize: size [
	size <= 16rf ifTrue: [
		outputStream nextPut: 16r90 + size.
	] ifFalse: [ 
		size <= 16rffff ifTrue: [ 
			outputStream nextPut: 16rDC.
			self nextPutUInt16: size
		] ifFalse: [ 
			self assert: size <= 16rffffffff.
			outputStream nextPut: 16rDD.
			self nextPutUInt32: size
		].
	].

]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeBoolean: value [
	outputStream nextPut: (value ifTrue: [ 16rC3 ] ifFalse: [ 16rC2 ])
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeByteArray: byteArray [
	| size |
	size := byteArray size.
	size <= 16rFF ifTrue: [
		outputStream nextPut: 16rC4; nextPut: size
	] ifFalse: [
		size <= 16rFFFF ifTrue: [ 
			outputStream nextPut: 16rC5.
			self nextPutUInt16: size
		] ifFalse: [
			self assert: size <= 16rFFFFFFFF.
			outputStream nextPut: 16rC6.
			self nextPutUInt32: size
		]
	].

	outputStream nextPutAll: byteArray
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeCharacter: character [
	^ self encodeExtension: character asString utf8Encoded type: MessagePackExtensionCodeCharacter
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeExtension: extensionData type: type [
	| size powerIndex |
	size := extensionData size.
	powerIndex := #(1 2 4 8 16) indexOf: size ifAbsent: [ 0 ].
	powerIndex > 0 ifTrue: [
		outputStream nextPut: 16rD4 + powerIndex - 1
	] ifFalse: [
		size <= 16rFF ifTrue: [
			outputStream nextPut: 16rC7; nextPut: size
		] ifFalse: [
			size <= 16rFFFF ifTrue: [ 
				outputStream nextPut: 16rC8.
				self nextPutUInt16: size
			] ifFalse: [
				self assert: size <= 16rFFFFFFFF.
				outputStream nextPut: 16rC9.
				self nextPutUInt32: size
			]
		]
	].

	outputStream nextPut: type & 16rff.
	outputStream nextPutAll: extensionData
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeFloat: value [
	| floatEncoding |
	floatEncoding := value asIEEE32BitWord.
	value = (Float fromIEEE32Bit: floatEncoding) ifTrue: [ 
		outputStream nextPut: 16rCA.
		self nextPutUInt32: floatEncoding
	] ifFalse: [ 
		outputStream nextPut: 16rCB.
		self nextPutUInt64: ((value basicAt: 1) << 32) | (value basicAt: 1)
	].

]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeInteger: value [
	value < 0 ifTrue: [
		value >= -32 ifTrue: [ ^ outputStream nextPut: value & 16rff ].
		value >= 16r80 negated ifTrue: [ ^ outputStream nextPut: 16rD0; nextPut: value & 16rff ].
		value >= 16r8000 negated ifTrue: [ outputStream nextPut: 16rD1. ^ self nextPutInt16: value ].
		value >= 16r80000000 negated ifTrue: [ outputStream nextPut: 16rD2. ^ self nextPutInt32: value ].
		value >= 16r8000000000000000 negated ifTrue: [ outputStream nextPut: 16rD3. ^ self nextPutInt64: value ].
	] ifFalse: [ 
		value <= 16r7f ifTrue: [ ^ outputStream nextPut: value ].
		value <= 16rff ifTrue: [ ^ outputStream nextPut: 16rCC; nextPut: value ].
		value <= 16rffff ifTrue: [ outputStream nextPut: 16rCD. ^ self nextPutUInt16: value ].
		value <= 16rffffffff ifTrue: [ outputStream nextPut: 16rCE. ^ self nextPutUInt32: value ].
		value <= 16rffffffffffffffff ifTrue: [ outputStream nextPut: 16rCF. ^ self nextPutUInt64: value ].
	].
	self error: 'Unsupported large integer'.

]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeMap: aDictionary [
	| size |
	size := aDictionary size.
	size <= 16rf ifTrue: [
		outputStream nextPut: 16r80 + size.
	] ifFalse: [ 
		size <= 16rffff ifTrue: [ 
			outputStream nextPut: 16rDE.
			self nextPutUInt16: size
		] ifFalse: [ 
			self assert: size <= 16rffffffff.
			outputStream nextPut: 16rDF.
			self nextPutUInt32: size
		].
	].

	aDictionary keysAndValuesDo: [:key :value |
		self encodeObject: key; encodeObject: value
	].
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeNil [
	outputStream nextPut: 16rC0
]

{ #category : #encoding }
SLVMMessagePackEncoder >> encodeObject: anObject [
	anObject slvmMessagePackEncodeWith: self
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeString: string [
	| encodedString size |
	encodedString := string utf8Encoded.
	size := encodedString size.
	size <= 31 ifTrue: [
		outputStream nextPut: 16rA0 + size
	] ifFalse: [
		size <= 16rFF ifTrue: [
			outputStream nextPut: 16rD9; nextPut: size
		] ifFalse: [
			size <= 16rFFFF ifTrue: [ 
				outputStream nextPut: 16rDA.
				self nextPutUInt16: size
			] ifFalse: [
				self assert: size <= 16rFFFFFFFF.
				outputStream nextPut: 16rDB.
				self nextPutUInt32: size
			]
		]
	].

	outputStream nextPutAll: encodedString
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> encodeSymbol: symbol [
	^ self encodeExtension: symbol utf8Encoded type: MessagePackExtensionCodeSymbol
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> nextPutInt16: value [
	self nextPutUInt16: value & 16rffff
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> nextPutInt32: value [
	self nextPutUInt32: value & 16rffffffff
]

{ #category : #'as yet unclassified' }
SLVMMessagePackEncoder >> nextPutInt64: value [
	self nextPutUInt64: value & 16rffffffffffffffff
]

{ #category : #encoding }
SLVMMessagePackEncoder >> nextPutUInt16: value [
	outputStream
		nextPut: value & 16rff;
		nextPut: (value >> 8) & 16rff
]

{ #category : #encoding }
SLVMMessagePackEncoder >> nextPutUInt32: value [
	outputStream
		nextPut: value & 16rff;
		nextPut: (value >> 8) & 16rff;
		nextPut: (value >> 16) & 16rff;
		nextPut: (value >> 24) & 16rff
]

{ #category : #encoding }
SLVMMessagePackEncoder >> nextPutUInt64: value [
	outputStream
		nextPut: value & 16rff;
		nextPut: (value >> 8) & 16rff;
		nextPut: (value >> 16) & 16rff;
		nextPut: (value >> 24) & 16rff;
		nextPut: (value >> 32) & 16rff;
		nextPut: (value >> 40) & 16rff;
		nextPut: (value >> 48) & 16rff;
		nextPut: (value >> 56) & 16rff
]

{ #category : #accessing }
SLVMMessagePackEncoder >> outputStream [
	^ outputStream
]

{ #category : #accessing }
SLVMMessagePackEncoder >> outputStream: anObject [
	outputStream := anObject
]
