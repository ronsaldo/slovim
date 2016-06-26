Class {
	#name : #SLVMInterferenceGraphBuilder,
	#superclass : #Object,
	#instVars : [
		'graph',
		'processedNodeDictionary'
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
SLVMInterferenceGraphBuilder >> processValue: aValue [
	| node paramNode actualParameters |
	processedNodeDictionary at: aValue ifPresent: [ :oldNode | ^ oldNode ].
	node := SLVMInterferenceGraphNode new variable: aValue.
	graph addNode: node.
	processedNodeDictionary at: aValue put: node.

	aValue isInstruction ifFalse: [ ^ node ].
	
	aValue isPhi ifTrue: [ 
		aValue parameters do: [ :param |
			paramNode := self processValue: param.
			node preferences add: paramNode.
			paramNode preferences add: node.
		].
	] ifFalse: [
		actualParameters := aValue parameters.
		aValue isCall ifTrue: [
			actualParameters := actualParameters allButFirst.
		].
	
		actualParameters do: [ :param |
			paramNode := self processValue: param.
			node interferences add: paramNode.
			paramNode interferences add: node.
		].
	].

	^ node
]
