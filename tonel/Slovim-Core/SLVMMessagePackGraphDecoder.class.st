Class {
	#name : #SLVMMessagePackGraphDecoder,
	#superclass : #SLVMMessagePackDecoder,
	#instVars : [
		'typeTable',
		'objectIDTable',
		'symbolTable'
	],
	#pools : [
		'SLVMSerializationGraphEncodingConstants'
	],
	#category : #'Slovim-Core-Serialization'
}

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> decodeArray: elementCount [
	| objectInstance |
	elementCount == 4 ifTrue: [
		| firstElement objectType earlyFields objectClass |
		firstElement := self decodeNext.
		(firstElement isSLVMMessagePackExtensionData not or: [ firstElement type ~~ MessagePackExtensionCodeGraphObjectDefinition ]) ifTrue: [ 
			^ { firstElement . self decodeNext . self decodeNext . self decodeNext }
		].
	
		objectType := self decodeNext.
		earlyFields := self decodeNext.
		objectClass := self objectClassForType: objectType.
		^ objectClass materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: self.
	].
	^ super decodeArray: elementCount
]

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> decodeExtension: extensionDataSize type: extensionType [
	extensionType == MessagePackExtensionCodeSymbolDefinition ifTrue: [
		| symbol |
		symbol := (inputStream next: extensionDataSize) utf8Decoded asSymbol.
		^ symbolTable add: symbol
	].
	extensionType == MessagePackExtensionCodeSymbolReference ifTrue: [ 
		^ symbolTable at: (self decodeLittleEndian: (inputStream next: extensionDataSize)) + 1
	].

	extensionType == MessagePackExtensionCodeGraphObjectReference ifTrue: [
		^ objectIDTable at: (self decodeLittleEndian: (inputStream next: extensionDataSize)) + 1
	].

	^ super decodeExtension: extensionDataSize type: extensionType
]

{ #category : #'as yet unclassified' }
SLVMMessagePackGraphDecoder >> decodeLittleEndian: byteArray [
	| size |
	size := byteArray size.
	size == 1 ifTrue: [ ^ byteArray at: 1 ].
	size == 2 ifTrue: [ ^ byteArray unsignedShortAt: 1 ].
	size == 4 ifTrue: [ ^ byteArray unsignedLongAt: 1 ].
	^ self error
]

{ #category : #initialization }
SLVMMessagePackGraphDecoder >> initialize [
	super initialize.
	objectIDTable := OrderedCollection new.
	symbolTable := OrderedCollection new.
]

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> objectClassForType: type [
	^ typeTable at: type ifAbsent: [ BasicTypeTableMap at: type ]
]

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> objectInstanceProxy: objectId concretizeWith: concreteObject [
	| proxy |
	proxy := objectIDTable at: objectId + 1.
	self assert: proxy class == Object.
	objectIDTable at: objectId + 1 put: concreteObject.	
	proxy becomeForward: concreteObject copyHash: false.

]

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> registerObjectInstance: objectInstance [
	| objectID |
	objectID := objectIDTable size.
	objectIDTable add: objectInstance.
	^ objectID
	
]

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> registerObjectInstanceProxy [
	^ self registerObjectInstance: Object new
]

{ #category : #accessing }
SLVMMessagePackGraphDecoder >> typeTable [
	^ typeTable
]

{ #category : #accessing }
SLVMMessagePackGraphDecoder >> typeTable: anObject [
	typeTable := anObject
]
