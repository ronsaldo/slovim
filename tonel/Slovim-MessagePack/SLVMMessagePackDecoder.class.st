Class {
	#name : #SLVMMessagePackDecoder,
	#superclass : #Object,
	#instVars : [
		'inputStream'
	],
	#classVars : [
		'DecodeDispatchTable'
	],
	#pools : [
		'SLVMMessagePackConstants'
	],
	#category : #'Slovim-MessagePack-Encoder'
}

{ #category : #converting }
SLVMMessagePackDecoder class >> decode: aByteArray [
	^ self decodeFrom: aByteArray readStream
]

{ #category : #converting }
SLVMMessagePackDecoder class >> decodeFrom: binaryStream [
	^ self new decodeFrom: binaryStream
]

{ #category : #'class initialization' }
SLVMMessagePackDecoder class >> initialize [
	"Message pack format decoding table according to https://github.com/msgpack/msgpack/blob/master/spec.md [March 11, 2020]"

	DecodeDispatchTable := Array new: 256.

	"Positive fixint"
	16r00 to: 16r7f do: [ :i |
		DecodeDispatchTable at: i + 1 put: [ :decoder | decoder decodeInteger: i ]
	].

	"Negative fixint"
	16rE0 to: 16rff do: [ :i |
		| value |
		value := (i & 16r7f) - (i & 16r80).
		DecodeDispatchTable at: i + 1 put: [ :decoder | decoder decodeInteger: value ]
	].
	
	"Fixmap"
	16r80 to: 16r8f do: [ :i |
		DecodeDispatchTable at: i + 1 put: [ :decoder | decoder decodeMap: i - 16r80 ]
	].

	"Fixarray"
	16r90 to: 16r9f do: [ :i |
		DecodeDispatchTable at: i + 1 put: [ :decoder | decoder decodeArray: i - 16r90 ]
	].

	"Fixstring"
	16ra0 to: 16rbf do: [ :i |
		DecodeDispatchTable at: i + 1 put: [ :decoder | decoder decodeString: i - 16ra0 ]
	].

	{
		"nil"
		16rC0 . [ :decoder | decoder decodeNil ].
		"(unusued)"
		16rC1 . [ :decoder | decoder decodeUnusedCode ].
		"false"
		16rC2 . [ :decoder | decoder decodeBoolean: false ].
		"true"
		16rC3 . [ :decoder | decoder decodeBoolean: true ].

		"bin8"
		16rC4 . [ :decoder | decoder decodeBinary: decoder nextUInt8 ].
		"bin16"
		16rC5 . [ :decoder | decoder decodeBinary: decoder nextUInt16 ].
		"bin32"
		16rC6 . [ :decoder | decoder decodeBinary: decoder nextUInt32 ].

		"ext8"
		16rC7 . [ :decoder | decoder decodeExtension: decoder nextUInt8 type: decoder nextUInt8].
		"ext16"
		16rC8 . [ :decoder | decoder decodeExtension: decoder nextUInt16 type: decoder nextUInt8 ].
		"ext32"
		16rC9 . [ :decoder | decoder decodeExtension: decoder nextUInt32 type: decoder nextUInt8 ].

		"float32"
		16rCA . [ :decoder | decoder decodeFloat: (Float fromIEEE32Bit: decoder nextUInt32)].
		"float64"
		16rCB . [ :decoder | decoder decodeFloat: (Float fromIEEE64Bit: decoder nextUInt64)].

		"uint8"
		16rCC . [ :decoder | decoder decodeInteger: decoder nextUInt8].
		"uint16"
		16rCD . [ :decoder | decoder decodeInteger: decoder nextUInt16].
		"uint32"
		16rCE . [ :decoder | decoder decodeInteger: decoder nextUInt32].
		"uint64"
		16rCF . [ :decoder | decoder decodeInteger: decoder nextUInt64].
		"int8"
		16rD0 . [ :decoder | decoder decodeInteger: decoder nextInt8].
		"int16"
		16rD1 . [ :decoder | decoder decodeInteger: decoder nextInt16].
		"int32"
		16rD2 . [ :decoder | decoder decodeInteger: decoder nextInt32].
		"int64"
		16rD3 . [ :decoder | decoder decodeInteger: decoder nextInt64].
		"fixext 1"
		16rD4 . [ :decoder | decoder decodeExtension: 1 type: decoder nextUInt8].
		"fixext 2"
		16rD5 . [ :decoder | decoder decodeExtension: 2 type: decoder nextUInt8].
		"fixext 4"
		16rD6 . [ :decoder | decoder decodeExtension: 4 type: decoder nextUInt8].
		"fixext 8"
		16rD7 . [ :decoder | decoder decodeExtension: 8 type: decoder nextUInt8].
		"fixext 16"
		16rD8 . [ :decoder | decoder decodeExtension: 16 type: decoder nextUInt8].

		"str8"
		16rD9 . [ :decoder | decoder decodeString: decoder nextUInt8 ].
		"str16"
		16rDA . [ :decoder | decoder decodeString: decoder nextUInt16 ].
		"str32"
		16rDB . [ :decoder | decoder decodeString: decoder nextUInt32 ].

		"array16"
		16rDC . [ :decoder | decoder decodeArray: decoder nextUInt16 ].
		"array32"
		16rDD . [ :decoder | decoder decodeArray: decoder nextUInt32 ].

		"map16"
		16rDE . [ :decoder | decoder decodeMap: decoder nextUInt16 ].
		"map32"
		16rDF . [ :decoder | decoder decodeMap: decoder nextUInt32 ].

	} pairsDo: [ :code :block |
		DecodeDispatchTable at: code + 1 put: block
	].

	DecodeDispatchTable do: [ :block |
		self assert: block ~~ nil
	].
]

{ #category : #encoding }
SLVMMessagePackDecoder >> decodeArray: elementCount [
	| result |
	result := Array new: elementCount.
	1 to: elementCount do: [ :i |
		result at: i put: self decodeNext
	].
	^ result
]

{ #category : #encoding }
SLVMMessagePackDecoder >> decodeBinary: elementCount [
	^ inputStream next: elementCount
]

{ #category : #encoding }
SLVMMessagePackDecoder >> decodeBoolean: value [
	^ value
]

{ #category : #'as yet unclassified' }
SLVMMessagePackDecoder >> decodeExtension: extensionDataSize type: extensionType [
	| extensionBinaryData |
	extensionBinaryData := inputStream next: extensionDataSize.
	extensionType == MessagePackExtensionCodeTimestamp ifTrue: [
		
		extensionDataSize = 4 ifTrue: [ 
			^ MessagePackExtensionCodeTimestampEpoch + (extensionBinaryData unsignedLongAt: 1 bigEndian: false) asSeconds. 
		].
		extensionDataSize = 8 ifTrue: [ 
			^ MessagePackExtensionCodeTimestampEpoch +
				((extensionBinaryData unsignedLongAt: 1 bigEndian: false) asNanoSeconds + 
				(extensionBinaryData unsignedLongAt: 5 bigEndian: false) asSeconds). 
		].

		extensionDataSize = 12 ifTrue: [ 
			^ MessagePackExtensionCodeTimestampEpoch +
				((extensionBinaryData unsignedLongAt: 1 bigEndian: false) asNanoSeconds + 
				(extensionBinaryData signedLongLongAt: 5) asSeconds). 
		].

	].

	extensionType  == MessagePackExtensionCodeSymbol ifTrue: [
		^ extensionBinaryData utf8Decoded asSymbol
	].

	^ SLVMMessagePackExtensionData data: extensionBinaryData type: extensionType
]

{ #category : #encoding }
SLVMMessagePackDecoder >> decodeFloat: value [
	^ value
]

{ #category : #actions }
SLVMMessagePackDecoder >> decodeFrom: binaryStream [
	inputStream := binaryStream.
	^ self decodeNext
]

{ #category : #encoding }
SLVMMessagePackDecoder >> decodeInteger: value [
	^ value
]

{ #category : #'as yet unclassified' }
SLVMMessagePackDecoder >> decodeMap: elementCount [
	| result |
	result := OrderedDictionary new: elementCount.
	1 to: elementCount do: [ :i |
		result at: self decodeNext put: self decodeNext
	].
	^ result
]

{ #category : #'as yet unclassified' }
SLVMMessagePackDecoder >> decodeNext [
	| format |
	format := inputStream next.
	^ (DecodeDispatchTable at: format + 1) value: self
]

{ #category : #'as yet unclassified' }
SLVMMessagePackDecoder >> decodeNil [
	^ nil
]

{ #category : #encoding }
SLVMMessagePackDecoder >> decodeString: elementCount [
	^ (inputStream next: elementCount) utf8Decoded
]

{ #category : #'as yet unclassified' }
SLVMMessagePackDecoder >> decodeUnusedCode [
	self error: 'Invalid unused format.'
]

{ #category : #accessing }
SLVMMessagePackDecoder >> inputStream [
	^ inputStream
]

{ #category : #accessing }
SLVMMessagePackDecoder >> inputStream: anObject [
	inputStream := anObject
]

{ #category : #parsing }
SLVMMessagePackDecoder >> nextInt16 [
	| v |
	v := self nextUInt16.
	^ (v & 16r7fff) - (v & 16r8000)
]

{ #category : #parsing }
SLVMMessagePackDecoder >> nextInt32 [
	| v |
	v := self nextUInt32.
	^ (v & 16r7fffffff) - (v & 16r80000000)
]

{ #category : #parsing }
SLVMMessagePackDecoder >> nextInt64 [
	| v |
	v := self nextUInt64.
	^ (v & 16r7fffffffffffffff) - (v & 16r8000000000000000)
]

{ #category : #parsing }
SLVMMessagePackDecoder >> nextInt8 [
	| v |
	v := inputStream next.
	^ (v & 16r7f) - (v & 16r80)
]

{ #category : #parsing }
SLVMMessagePackDecoder >> nextUInt16 [
	^ inputStream next |
	(inputStream next << 8)
]

{ #category : #parsing }
SLVMMessagePackDecoder >> nextUInt32 [
	^ inputStream next |
	(inputStream next << 8) |
	(inputStream next << 16) |
	(inputStream next << 24)
]

{ #category : #parsing }
SLVMMessagePackDecoder >> nextUInt64 [
	^ inputStream next |
	(inputStream next << 8) |
	(inputStream next << 16) |
	(inputStream next << 24) |
	(inputStream next << 32) |
	(inputStream next << 40) |
	(inputStream next << 48) |
	(inputStream next << 56)
]

{ #category : #parsing }
SLVMMessagePackDecoder >> nextUInt8 [
	^ inputStream next
]
