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

{ #category : #'as yet unclassified' }
SLVMCast class >> source: source targetType: valueType [
	^ self new source: source targetType: valueType
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
