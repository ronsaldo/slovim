"
I am liveness analyzer that computes precise liveness information.
"
Class {
	#name : #SLVMLivenessAnalyzer,
	#superclass : #Object,
	#instVars : [
		'visitedBlocks',
		'liveInSets',
		'liveOutSets',
		'alwaysAlive',
		'liveElementCount',
		'liveInBitmap',
		'liveOutBitmap',
		'globalLiveElementCount',
		'liveVariables',
		'blockCount'
	],
	#category : #'Slovim-Core-Analysis'
}

{ #category : #building }
SLVMLivenessAnalyzer class >> analyze: aFunction [
	^ self new analyze: aFunction
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> analyze: aFunction [
	self enumerateFunctionElements: aFunction.
	
	globalLiveElementCount := aFunction arguments size.
	blockCount := aFunction basicBlocks size.
	
	liveInBitmap := SLVMBitmap width: liveElementCount - globalLiveElementCount height: liveElementCount - blockCount.
	liveOutBitmap := SLVMBitmap width: liveElementCount - globalLiveElementCount height: liveElementCount - blockCount.

	alwaysAlive := Set new.
	aFunction arguments do: [ :arg |
		liveInBitmap setRow: arg livenessIndex - blockCount.
		liveOutBitmap setRow: arg livenessIndex - blockCount.
		alwaysAlive add: arg.
	].
	
	liveInSets := Dictionary new.
	liveOutSets := Dictionary new.
	
	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :instruction |
			instruction hasOutputs ifTrue: [
				self processValue: instruction
			]
		]
	].

	^ SLVMLivenessInformation new function: aFunction;
		liveInSets: liveInSets;
		liveOutSets: liveOutSets;
		liveVariables: liveVariables;
		liveInBitmap: liveInBitmap;
		liveOutBitmap: liveOutBitmap
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> createLiveSet [
	^ alwaysAlive
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> enumerateFunctionElements: aFunction [
	liveElementCount := aFunction basicBlocks size.
	liveVariables := OrderedCollection new.
	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :instruction |
			liveElementCount := liveElementCount + 1.
			instruction livenessIndex: liveElementCount.
			liveVariables add: instruction.
		]
	].

	aFunction arguments do: [ :argument |
		liveElementCount := liveElementCount + 1.
		argument livenessIndex: liveElementCount.
		liveVariables add: argument.
	].
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> mark: value liveIn: element [
	| set |
	set := liveInSets at: element ifAbsentPut: [ self createLiveSet ].
	set add: value.
	liveInBitmap atRow: value livenessIndex - blockCount column: element livenessIndex put: true
]

{ #category : #'as yet unclassified' }
SLVMLivenessAnalyzer >> mark: value liveOut: element [
	| set |
	set := liveOutSets at: element ifAbsentPut: [ self createLiveSet ].
	set add: value.
	liveOutBitmap atRow: value livenessIndex - blockCount column: element livenessIndex put: true.
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
