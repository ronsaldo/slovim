Class {
	#name : #SLVMInterferenceGraphBuilder,
	#superclass : #Object,
	#instVars : [
		'graph',
		'processedNodeDictionary',
		'visitedBlocks'
	],
	#category : #'Slovim-Core-RegisterAllocation'
}

{ #category : #building }
SLVMInterferenceGraphBuilder class >> buildFor: aFunction [
	^ self new buildFor: aFunction
]

{ #category : #building }
SLVMInterferenceGraphBuilder >> buildFor: aFunction [
	processedNodeDictionary := Dictionary new.
	graph := SLVMInterferenceGraph new.
	
	aFunction basicBlocks do: [ :bb |
		bb instructions do: [ :instruction |
			instruction hasOutputs ifTrue: [
				self processValue: instruction
			]
		]
	].

	^ graph
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> interfere: firstValue with: secondValue [
	| firstNode secondNode |
	firstNode := self nodeFor: firstValue.
	secondNode := self nodeFor: secondValue.
	firstNode interferences add: secondNode.
	secondNode interferences add: firstNode.
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> nodeFor: value [
	| node |
	^ processedNodeDictionary at: value ifAbsentPut: [
		node := SLVMInterferenceGraphNode new variable: value.
		graph addNode: node.
		node ]
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> processValue: value [
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
SLVMInterferenceGraphBuilder >> value: value liveInAtInstruction: instruction [
	self value: value liveOutAtInstruction: instruction
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> value: value liveOutAtBlock: block [
	(visitedBlocks includes: block) ifTrue: [ ^ self ].
	visitedBlocks add: block.
	
	self value: value liveOutAtInstruction: block instructions last 
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> value: value liveOutAtInstruction: instruction [
	| currentInstruction |
	currentInstruction := instruction.
	[ currentInstruction isNotNil and: [ currentInstruction ~~ value ] ] whileTrue: [ 
		self interfere: value with: currentInstruction.
		currentInstruction := currentInstruction previousInstruction
	].

	currentInstruction ifNil: [
		instruction block predecessors do: [ :pred |
			self value: value liveOutAtBlock: pred
		]
	].

]
