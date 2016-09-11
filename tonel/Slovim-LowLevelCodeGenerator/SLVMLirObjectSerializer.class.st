Class {
	#name : #SLVMLirObjectSerializer,
	#superclass : #Object,
	#instVars : [
		'dictionary',
		'relocationList',
		'stream',
		'pointerSize'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #adding }
SLVMLirObjectSerializer >> addInnerObject: anObject [
	| oldPosition pointer |
	oldPosition := stream position.
	pointer := self addObject: anObject.
	stream position: oldPosition.
	pointerSize = 4 ifTrue: [
		self writeInt32: pointer
	] ifFalse: [ 
		self writeInt64: pointer
	].
]

{ #category : #adding }
SLVMLirObjectSerializer >> addObject: anObject [
	| startPosition elementCount class elementSize bodySize slotCount actualBodySize bodyPosition header format extraBits |
	(self isImmediate: anObject) ifTrue: [
		^ self encodeImmediate: anObject
	].
	startPosition := dictionary at: anObject ifPresent: [ :pointer | ^ pointer ] ifAbsentPut: [ stream size alignedTo: 16 ].

	"Align the objects to 16 bytes boundaries."
	stream position: stream size.
	[ stream size < startPosition ] whileTrue: [ stream nextPut: 0 ].

	elementCount := self objectElementCount: anObject.
	
	"Compute the size of the body"
	class := anObject class.
	elementSize := self objectElementSizeFor: class instSpec.
	bodySize := elementCount * elementSize.
	actualBodySize := bodySize alignedTo: pointerSize.
	slotCount := actualBodySize // pointerSize.
		
	"ToDo: write the object header"	
	slotCount >= 255 ifTrue: [
		self
			writeInt64: 1;
			writeInt64: 0;
			writeInt64: slotCount.
	] ifFalse: [ 
		self writeInt64: 0.
	].

	format := class instSpec.
	extraBits := elementSize - (elementCount % elementSize).
	format := extraBits + extraBits.
	
	header := self classIndexFor: class.
	header := header | (format << 24).
	header := header | (anObject identityHash << 32).
	header := header | ((slotCount min: 255) << 56).
	self writeInt64: header.

	class isPointers ifTrue: [
		bodyPosition := stream position.
		1 to: bodySize do: [ :i |
			stream nextPut: 0
		].
	
		stream position: bodyPosition.
		1 to: elementCount do: [ :slot |
			self addInnerObject: (anObject instVarAt: slot)
		].
	] ifFalse: [
		elementSize = 8 ifTrue: [
			self halt
		].
		elementSize = 4 ifTrue: [
			self halt
		].
		elementSize = 2 ifTrue: [
			self halt
		].
		elementSize = 1 ifTrue: [
			1 to: bodySize do: [ :i |
				stream nextPut: (anObject byteAt: i)
			].
		
			bodySize + 1 to: actualBodySize do: [ :i |
				stream nextPut: 0
			]
		].
	].

	^ startPosition + (slotCount >= 255 ifTrue: [ 24 ] ifFalse: [ 8 ])
]

{ #category : #adding }
SLVMLirObjectSerializer >> classIndexFor: aClass [
	^ 0
]

{ #category : #accessing }
SLVMLirObjectSerializer >> contents [
	^ stream contents
]

{ #category : #adding }
SLVMLirObjectSerializer >> encodeImmediate32: anObject [
	anObject isInteger ifTrue: [ ^ anObject << 1 | 1].
	self halt
]

{ #category : #adding }
SLVMLirObjectSerializer >> encodeImmediate64: anObject [
	anObject isInteger ifTrue: [ ^ anObject << 3 | 1].
	self halt
]

{ #category : #adding }
SLVMLirObjectSerializer >> encodeImmediate: anObject [
	pointerSize = 4 ifTrue: [
		^ self encodeImmediate32: anObject
	] ifFalse: [
		^ self encodeImmediate64: anObject
	]
]

{ #category : #initialization }
SLVMLirObjectSerializer >> initialize [
	super initialize.
	stream := ReadWriteStream on: (ByteArray new: 100).
	stream binary.
	dictionary := IdentityDictionary new.
]

{ #category : #adding }
SLVMLirObjectSerializer >> isImmediate: anObject [
	anObject isInteger ifTrue: [ ^ true ].
	anObject isCharacter ifTrue: [ ^ true ].
	^ false
]

{ #category : #adding }
SLVMLirObjectSerializer >> objectElementCount: anObject [
	anObject class isPointers ifTrue: [ 
		^ anObject class instVarNames size + (anObject class isVariable ifTrue: [ anObject size ] ifFalse: [ 0 ])
	] ifFalse: [
		^ anObject size
	]
]

{ #category : #adding }
SLVMLirObjectSerializer >> objectElementSizeFor: format [
	format < 6 ifTrue: [ ^ pointerSize ].
	format < 10 ifTrue: [ ^ 8 ].
	format < 12 ifTrue: [ ^ 4 ].
	format < 16 ifTrue: [ ^ 2 ].
	^ 1
]

{ #category : #accessing }
SLVMLirObjectSerializer >> pointerSize [
	^ pointerSize
]

{ #category : #accessing }
SLVMLirObjectSerializer >> pointerSize: anObject [
	pointerSize := anObject
]

{ #category : #adding }
SLVMLirObjectSerializer >> writeInt16: value [
	stream nextPut: (value bitAnd: 16rff).
	stream nextPut: ((value >> 8) bitAnd: 16rff).
]

{ #category : #adding }
SLVMLirObjectSerializer >> writeInt32: value [
	stream nextPut: (value bitAnd: 16rff).
	stream nextPut: ((value >> 8) bitAnd: 16rff).
	stream nextPut: ((value >> 16) bitAnd: 16rff).
	stream nextPut: ((value >> 24) bitAnd: 16rff).
]

{ #category : #adding }
SLVMLirObjectSerializer >> writeInt64: value [
	stream nextPut: (value bitAnd: 16rff).
	stream nextPut: ((value >> 8) bitAnd: 16rff).
	stream nextPut: ((value >> 16) bitAnd: 16rff).
	stream nextPut: ((value >> 24) bitAnd: 16rff).
	stream nextPut: ((value >> 32) bitAnd: 16rff).
	stream nextPut: ((value >> 40) bitAnd: 16rff).
	stream nextPut: ((value >> 48) bitAnd: 16rff).
	stream nextPut: ((value >> 56) bitAnd: 16rff).
]
