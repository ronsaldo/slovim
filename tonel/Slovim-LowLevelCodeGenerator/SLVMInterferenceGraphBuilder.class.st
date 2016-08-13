Class {
	#name : #SLVMInterferenceGraphBuilder,
	#superclass : #Object,
	#instVars : [
		'instructionDictionary',
		'graph'
	],
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder class >> buildForLiveness: liveness [
	^ self new buildForLiveness: liveness
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> buildForLiveness: liveness [
	instructionDictionary := Dictionary new.
	graph := SLVMInterferenceGraph new.
	liveness function basicBlocks do: [ :block |
		self combineLiveSets: liveness At: block.
		block instructionsDo: [ :instruction |
			self combineLiveSets: liveness At: instruction
		]
	].

	^ graph
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> combineLiveSets: liveness At: element [
	| liveInSet liveOutSet varSet |
	liveInSet := liveness liveInSets at: element ifAbsent: #().
	liveOutSet := liveness liveOutSets at: element ifAbsent: #().
	varSet := liveInSet union: liveOutSet.
	varSet size = 1 ifTrue: [
		self nodeForInstruction: varSet anyOne.
	].

	varSet do: [ :a |
		varSet do: [ :b |
		a ~~ b ifTrue: [ self interfere: a with: b ]
		]
	]
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> interfere: a with: b [
	| nodeA nodeB |
	nodeA := self nodeForInstruction: a.
	nodeB := self nodeForInstruction: b.
	nodeA interferences add: nodeB.
	nodeB interferences add: nodeA.
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphBuilder >> nodeForInstruction: anInstruction [
	| node |
	^ instructionDictionary at: anInstruction ifAbsentPut: [ 
		node := SLVMInterferenceGraphNode new variable: anInstruction.
		graph addNode: node.
		node
	]
]
