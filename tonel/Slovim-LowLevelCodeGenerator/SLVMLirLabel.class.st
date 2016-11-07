Class {
	#name : #SLVMLirLabel,
	#superclass : #SLVMLirExternalLabel,
	#instVars : [
		'contentSize'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirLabel >> contentSize [
	^ contentSize
]

{ #category : #accessing }
SLVMLirLabel >> contentSize: anObject [
	contentSize := anObject
]

{ #category : #copying }
SLVMLirLabel >> copyReplaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction [
	^ blockLabelDictionary at: self
]

{ #category : #initialization }
SLVMLirLabel >> initialize [
	super initialize.
	visibility := #private.
	contentSize := 0.
]

{ #category : #'as yet unclassified' }
SLVMLirLabel >> isExternalLabel [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMLirLabel >> relocatableValue [
	^ self offset
]

{ #category : #testing }
SLVMLirLabel >> value [
	^ offset
]
