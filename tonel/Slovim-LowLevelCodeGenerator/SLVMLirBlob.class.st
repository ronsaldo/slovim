Class {
	#name : #SLVMLirBlob,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'content',
		'relocations'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirBlob class >> content: aByteArray [
	^ self new content: aByteArray
]

{ #category : #accessing }
SLVMLirBlob >> content [
	^ content
]

{ #category : #accessing }
SLVMLirBlob >> content: anObject [
	content := anObject.
	self size: content size
]

{ #category : #copying }
SLVMLirBlob >> copyReplaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction [
	^ self
]

{ #category : #initialization }
SLVMLirBlob >> initialize [
	super initialize.
	relocations := #().
]

{ #category : #testing }
SLVMLirBlob >> isBlob [
	^ true
]

{ #category : #accessing }
SLVMLirBlob >> relocations [
	^ relocations
]

{ #category : #accessing }
SLVMLirBlob >> relocations: anObject [
	relocations := anObject
]
