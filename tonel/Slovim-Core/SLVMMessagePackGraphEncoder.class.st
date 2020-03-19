Class {
	#name : #SLVMMessagePackGraphEncoder,
	#superclass : #SLVMMessagePackEncoder,
	#instVars : [
		'objectIDCount'
	],
	#category : #'Slovim-Core-Serialization'
}

{ #category : #'as yet unclassified' }
SLVMMessagePackGraphEncoder >> encodeSerializationGraphObject: object [
	object id ifNil: [
		object id: objectIDCount.
		objectIDCount := objectIDCount + 1.
		self
			encodeArray: {
				SLVMMessagePackExtensionData data: (ByteArray new: 1) type: MessagePackExtensionCodeGraphObjectDefinition.
				object type.
				object earlyFields.
				object fields
			}.
	] ifNotNil: [ :id |
		self
			encodeExtension: ((ByteArray new: 4)
				unsignedLongAt: 1 put: id bigEndian: false;
				yourself)
				type: MessagePackExtensionCodeGraphObjectReference
	].
]

{ #category : #initialization }
SLVMMessagePackGraphEncoder >> initialize [
	super initialize.
	objectIDCount := 0.
]
