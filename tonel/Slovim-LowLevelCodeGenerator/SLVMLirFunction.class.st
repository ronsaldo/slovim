Class {
	#name : #SLVMLirFunction,
	#superclass : #Object,
	#instVars : [
		'compilationTarget',
		'stackFrame',
		'variableMap',
		'basicBlocks'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #adding }
SLVMLirFunction >> addBasicBlock: aBasicBlock [
	aBasicBlock function: self.
	basicBlocks add: aBasicBlock.
]

{ #category : #adding }
SLVMLirFunction >> addFirstBasicBlock: aBasicBlock [
	aBasicBlock function: self.
	basicBlocks addFirst: aBasicBlock.
]

{ #category : #'as yet unclassified' }
SLVMLirFunction >> asInstructionStream [
	| result blockToLabelMap label |
	result := SLVMLirInstructionStream new compilationTarget: compilationTarget.
	blockToLabelMap := Dictionary new.
	basicBlocks do: [ :bb |
		label := SLVMLirLabel new name: bb name.
		blockToLabelMap at: bb put: label
	].

	basicBlocks do: [ :bb |
		label := blockToLabelMap at: bb.
		result add: label.
		bb instructions do: [ :ins |
			result add: (ins copyReplaceBlocksWith: blockToLabelMap)
		]
	].

	^ result
]

{ #category : #accessing }
SLVMLirFunction >> basicBlocks [
	^ basicBlocks
]

{ #category : #accessing }
SLVMLirFunction >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirFunction >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #initialization }
SLVMLirFunction >> initialize [
	basicBlocks := OrderedCollection new.
	compilationTarget := SLVM32BitsPointerCompilationTarget new.
	stackFrame := SLVMLirStackFrame new.
	variableMap := Dictionary new.
]

{ #category : #'as yet unclassified' }
SLVMLirFunction >> mapSSA: value toStackVariable: local [
	variableMap at: value put: local.
]

{ #category : #printing }
SLVMLirFunction >> printOn: aStream [
	basicBlocks do: [ :bb | bb fullPrintOn: aStream ].
]

{ #category : #accessing }
SLVMLirFunction >> stackFrame [
	^ stackFrame
]

{ #category : #accessing }
SLVMLirFunction >> variableMap [
	^ variableMap
]
