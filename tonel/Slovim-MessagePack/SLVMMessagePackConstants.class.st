Class {
	#name : #SLVMMessagePackConstants,
	#superclass : #SharedPool,
	#classVars : [
		'MessagePackExtensionCodeSymbol',
		'MessagePackExtensionCodeTimestamp',
		'MessagePackExtensionCodeTimestampEpoch'
	],
	#category : #'Slovim-MessagePack-Encoder'
}

{ #category : #'class initialization' }
SLVMMessagePackConstants class >> initialize [
	MessagePackExtensionCodeSymbol := 1.
	MessagePackExtensionCodeTimestamp := 255.
	MessagePackExtensionCodeTimestampEpoch := DateAndTime unixEpoch.
]
