Class {
	#name : #SLVMMessagePackGraphDecoder,
	#superclass : #SLVMMessagePackDecoder,
	#instVars : [
		'typeTable',
		'objectIDTable',
		'objectIDCount'
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
	extensionType == MessagePackExtensionCodeGraphObjectReference ifTrue: [ 
		self assert: extensionDataSize = 4.
		^ objectIDTable at: ((inputStream next: extensionDataSize)
			unsignedLongAt: 1 bigEndian: false)
	].

	^ super decodeExtension: extensionDataSize type: extensionType
]

{ #category : #initialization }
SLVMMessagePackGraphDecoder >> initialize [
	super initialize.
	objectIDTable := Dictionary new.
	objectIDCount := 0.
]

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> objectClassForType: type [
	^ typeTable at: type ifAbsent: [ BasicTypeTableMap at: type ]
]

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> objectInstanceProxy: objectId concretizeWith: concreteObject [
	| proxy |
	proxy := objectIDTable at: objectId.
	self assert: proxy class == Object.
	objectIDTable at: objectId put: concreteObject.	
	proxy becomeForward: concreteObject.

]

{ #category : #encoding }
SLVMMessagePackGraphDecoder >> registerObjectInstance: objectInstance [
	| objectID |
	objectID := objectIDCount.
	objectIDTable at: objectID put: objectInstance.
	objectIDCount := objectIDCount + 1.
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
