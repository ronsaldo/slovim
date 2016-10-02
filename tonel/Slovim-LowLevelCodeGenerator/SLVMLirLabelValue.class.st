Class {
	#name : #SLVMLirLabelValue,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'label',
		'labelOffset'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #arithmetic }
SLVMLirLabelValue >> + extraOffset [
	^ self copy labelOffset: labelOffset + extraOffset
]

{ #category : #converting }
SLVMLirLabelValue >> asX86Ptr [
	^ self asX86PtrOfSize: 4
]

{ #category : #converting }
SLVMLirLabelValue >> asX86PtrOfSize: accessSize [
	^ SLVMLirX86RegisterAddress new size: accessSize; displacement: self
]

{ #category : #copying }
SLVMLirLabelValue >> copyReplaceModuleElementsWith: moduleElementDictionary replaceBlocksWith: blockLabelDictionary lowerVariablesWith: lirFunction [
	^ self copy label: (moduleElementDictionary at: label ifAbsent: [ blockLabelDictionary at: label ])
]

{ #category : #testing }
SLVMLirLabelValue >> isImmediate [
	^ true
]

{ #category : #testing }
SLVMLirLabelValue >> isLabelValue [
	^ true
]

{ #category : #testing }
SLVMLirLabelValue >> isSmallImmediate [
	^ false
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

{ #category : #'as yet unclassified' }
SLVMLirLabelValue >> printOn: aStream [
	aStream print: label ; nextPutAll: ' + '; print: labelOffset
]
