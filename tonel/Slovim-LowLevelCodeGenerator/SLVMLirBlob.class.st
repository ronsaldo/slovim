Class {
	#name : #SLVMLirBlob,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'content'
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

{ #category : #'as yet unclassified' }
SLVMLirBlob >> isBlob [
	^ true
]
