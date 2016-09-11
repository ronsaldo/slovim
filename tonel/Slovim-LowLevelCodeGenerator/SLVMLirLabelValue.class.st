Class {
	#name : #SLVMLirLabelValue,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'label',
		'labelOffset'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'as yet unclassified' }
SLVMLirLabelValue >> copyReplaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction [
	^ self copy label: (moduleElementDictionary at: label ifAbsent: [ blockLabelDictionary at: label ])
]

{ #category : #testing }
SLVMLirLabelValue >> isLabelValue [
	^ true
]

{ #category : #accessing }
SLVMLirLabelValue >> label [
	^ label
]

{ #category : #accessing }
SLVMLirLabelValue >> label: anObject [
	label := anObject
]

{ #category : #accessing }
SLVMLirLabelValue >> labelOffset [
	^ labelOffset
]

{ #category : #accessing }
SLVMLirLabelValue >> labelOffset: anObject [
	labelOffset := anObject
]
