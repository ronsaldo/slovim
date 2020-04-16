Class {
	#name : #SLVMSampleInstruction,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMSampleInstruction class >> isAbstract [
	^ self == SLVMSampleInstruction
]

{ #category : #'as yet unclassified' }
SLVMSampleInstruction >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType.
]

{ #category : #accessing }
SLVMSampleInstruction >> sampledTexture [
	^ parameters first
]

{ #category : #accessing }
SLVMSampleInstruction >> texcoord [
	^ parameters second
]

{ #category : #accessing }
SLVMSampleInstruction >> type [
	^ type
]
