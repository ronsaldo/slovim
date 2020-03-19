Class {
	#name : #SLVMMessagePackConstants,
	#superclass : #SharedPool,
	#classVars : [
		'MessagePackExtensionCodeCharacter',
		'MessagePackExtensionCodeGraphObjectDefinition',
		'MessagePackExtensionCodeGraphObjectReference',
		'MessagePackExtensionCodeSymbol',
		'MessagePackExtensionCodeTimestamp',
		'MessagePackExtensionCodeTimestampEpoch'
	],
	#category : #'Slovim-MessagePack-Encoder'
}

{ #category : #'class initialization' }
SLVMMessagePackConstants class >> initialize [
	MessagePackExtensionCodeSymbol := 1.
	MessagePackExtensionCodeCharacter := 2.
	MessagePackExtensionCodeGraphObjectDefinition := 3.
	MessagePackExtensionCodeGraphObjectReference := 4.
	MessagePackExtensionCodeTimestamp := 255.
	MessagePackExtensionCodeTimestampEpoch := DateAndTime unixEpoch.
]
