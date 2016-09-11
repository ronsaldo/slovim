Class {
	#name : #SLVMLirFunction,
	#superclass : #SLVMLirModuleElement,
	#instVars : [
		'name',
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

{ #category : #printing }
SLVMLirFunction >> fullPrintOn: aStream [
	self printOn: aStream.
	aStream nextPut: $:; cr.
	basicBlocks do: [ :bb | bb fullPrintOn: aStream ].
]

{ #category : #initialization }
SLVMLirFunction >> initialize [
	basicBlocks := OrderedCollection new.
	compilationTarget := SLVM32BitsPointerCompilationTarget new.
	stackFrame := SLVMLirStackFrame new.
	variableMap := Dictionary new.
]

{ #category : #'as yet unclassified' }
SLVMLirFunction >> isExternal [
	^ basicBlocks isEmpty
]

{ #category : #accessing }
SLVMLirFunction >> labelType [
	^ #function
]

{ #category : #'as yet unclassified' }
SLVMLirFunction >> lowerVariable: stackFrameVariable [
	^ compilationTarget lowerLocalVariable: stackFrameVariable in: stackFrame
]

{ #category : #'as yet unclassified' }
SLVMLirFunction >> mapSSA: value toStackVariable: local [
	variableMap at: value put: local.
]

{ #category : #accessing }
SLVMLirFunction >> name [
	^ name
]

{ #category : #accessing }
SLVMLirFunction >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMLirFunction >> printOn: aStream [
	name ifNil: [ ^ aStream nextPutAll: '<anonymous_function>' ].
	aStream nextPutAll: name
]

{ #category : #'as yet unclassified' }
SLVMLirFunction >> section [
	^ #'.text'
]

{ #category : #accessing }
SLVMLirFunction >> stackFrame [
	^ stackFrame
]

{ #category : #accessing }
SLVMLirFunction >> variableMap [
	^ variableMap
]

{ #category : #'as yet unclassified' }
SLVMLirFunction >> writeToInstructionStream: instructionStream moduleElementDictionary: moduleElementDictionary [
	| blockToLabelMap label |
	blockToLabelMap := Dictionary new.
	basicBlocks do: [ :bb |
		label := SLVMLirLabel new name: bb name.
		blockToLabelMap at: bb put: label.
		bb instructions do: [ :ins |
			ins isLabel ifTrue: [ blockToLabelMap at: ins put: ins copy ]
		]
	].

	basicBlocks do: [ :bb |
		label := blockToLabelMap at: bb.
		instructionStream withSectionNamed: bb sectionName do: [
			instructionStream add: label.
			bb instructions do: [ :ins |
				instructionStream add: (
					ins
						copyReplaceModuleElementsWith: moduleElementDictionary
						replaceBlocksWith: blockToLabelMap
						lowerVariablesWith: self)
			]
		]
	].
]
