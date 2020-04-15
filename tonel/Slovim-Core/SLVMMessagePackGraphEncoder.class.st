Class {
	#name : #SLVMMessagePackGraphEncoder,
	#superclass : #SLVMMessagePackEncoder,
	#instVars : [
		'usedSymbolTable',
		'objectIDCount'
	],
	#category : #'Slovim-Core-Serialization'
}

{ #category : #'as yet unclassified' }
SLVMMessagePackGraphEncoder >> encodeLittleEndianInteger: value [
	value <= 16rFF ifTrue: [ ^ ByteArray with: value ].
	value <= 16rFFFF ifTrue: [ ^ ByteArray with: value & 16rFF with: (value>>8) & 16rFF ].
	
	^ (ByteArray new: 4)
		unsignedLongAt: 1 put: value;
		yourself
]

{ #category : #'as yet unclassified' }
SLVMMessagePackGraphEncoder >> encodeSerializationGraphObject: object [
	object id ifNil: [
		object id: #encoding.
		self
			encodeArraySize: 4;
			encodeObject: (SLVMMessagePackExtensionData data: (ByteArray new: 1) type: MessagePackExtensionCodeGraphObjectDefinition);
			encodeObject: object type;
			encodeObject: object earlyFields.
		
		object id: objectIDCount.
		objectIDCount := objectIDCount + 1.
		self encodeObject: object fields.
	] ifNotNil: [ :id |
		self assert: id isInteger.
		self
			encodeExtension: (self encodeLittleEndianInteger: id)
			type: MessagePackExtensionCodeGraphObjectReference
	].
]

{ #category : #'as yet unclassified' }
SLVMMessagePackGraphEncoder >> encodeSymbol: symbol [
	usedSymbolTable at: symbol ifPresent: [ :found |
		self encodeExtension: found type: MessagePackExtensionCodeSymbolReference
	] ifAbsentPut: [
		| pointerBytes |
		pointerBytes := self encodeLittleEndianInteger: usedSymbolTable size.
		self encodeExtension: symbol utf8Encoded type: MessagePackExtensionCodeSymbolDefinition.		
		pointerBytes
	].
]

{ #category : #initialization }
SLVMMessagePackGraphEncoder >> initialize [
	super initialize.
	usedSymbolTable := IdentityDictionary new.
	objectIDCount := 0.
]
