Class {
	#name : #SLVMLivenessAnalyzer,
	#superclass : #Object,
	#instVars : [
		'visitedBlocks',
		'liveInSets',
		'liveOutSets'
	],
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #building }
SLVMLivenessAnalyzer class >> analyze: aFunction [
	^ self new analyze: aFunction
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> analyze: aFunction [
	liveInSets := Dictionary new.
	liveOutSets := Dictionary new.
	
	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :instruction |
			instruction hasOutputs ifTrue: [
				self processValue: instruction
			]
		]
	].

	^ SLVMLivenessInformation new function: aFunction; liveInSets: liveInSets; liveOutSets: liveOutSets
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> mark: value liveIn: element [
	| set |
	set := liveInSets at: element ifAbsentPut: [ Set new ].
	set add: value
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> mark: value liveOut: element [
	| set |
	set := liveOutSets at: element ifAbsentPut: [ Set new ].
	set add: value
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> processValue: value [
	visitedBlocks := Set new.
	value instructionReferences do: [ :ref |
		ref isPhi ifTrue: [
			ref valuesAndParentsDo: [ :usage :predecessor |
				usage = value ifTrue: [
					self value: value liveOutAtBlock: predecessor
				]
			]
		] ifFalse: [
			self value: value liveInAtInstruction: ref
		]
	]
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> value: value liveInAtInstruction: instruction [
	self mark: value liveIn: instruction.
	instruction previousInstruction ifNil: [
		self mark: value liveIn: instruction block. 
		instruction block predecessors do: [ :pred |
			self value: value liveOutAtBlock: pred
		]
	] ifNotNil: [
		self value: value liveOutAtInstruction: instruction previousInstruction.
	]
	
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> value: value liveOutAtBlock: block [
	(visitedBlocks includes: block) ifTrue: [ ^ self ].
	visitedBlocks add: block.
	self mark: value liveOut: block.
	
	self value: value liveOutAtInstruction: block lastInstruction
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> value: value liveOutAtInstruction: instruction [
	self mark: value liveOut: instruction.
	instruction ~~ value ifTrue: [ 
		self value: value liveInAtInstruction: instruction
	].

]
