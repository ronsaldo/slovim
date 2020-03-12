Class {
	#name : #SLVMMessagePackConstants,
	#superclass : #SharedPool,
	#classVars : [
		'MessagePackExtensionCodeCharacter',
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
	MessagePackExtensionCodeTimestamp := 255.
	MessagePackExtensionCodeTimestampEpoch := DateAndTime unixEpoch.
]
