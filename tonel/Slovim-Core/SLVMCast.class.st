"
I am a casting instruction.
"
Class {
	#name : #SLVMCast,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMCast class >> isAbstract [
	^ self == SLVMCast
]

{ #category : #'as yet unclassified' }
SLVMCast class >> source: source targetType: valueType [
	^ self new source: source targetType: valueType
]

{ #category : #'as yet unclassified' }
SLVMCast >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType
]

{ #category : #testing }
SLVMCast >> isPureInstruction [
	^ true
]

{ #category : #accessing }
SLVMCast >> source [
	^ parameters first
]

{ #category : #'as yet unclassified' }
SLVMCast >> source: source targetType: targetType [
	self parameters: { source }.
	type := targetType
	
]

{ #category : #accessing }
SLVMCast >> type [
	^ type
]
