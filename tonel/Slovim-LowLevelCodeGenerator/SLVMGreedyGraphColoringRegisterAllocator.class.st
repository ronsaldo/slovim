Class {
	#name : #SLVMGreedyGraphColoringRegisterAllocator,
	#superclass : #SLVMGraphColoringRegisterAllocator,
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #'graph coloring' }
SLVMGreedyGraphColoringRegisterAllocator >> graphColoringOrdering: interferenceGraph [
	"Welsh-Powell algorithm"
	| nodesByDegree order processedNodes nodes |
	nodes := interferenceGraph nodes.
	nodesByDegree := nodes sorted: [ :a :b | a interferences size > b interferences size ].
	order := OrderedCollection new.
	processedNodes := Set new.
	
	nodesByDegree do: [ :node|
		(processedNodes includes: node) ifFalse: [
			order add: node.
			processedNodes add: node.
			nodesByDegree do: [ :candidate |
				((processedNodes includes: candidate) not and: [ (candidate interferences includes: node) not ]) ifTrue: [ 
					order add: candidate.
					processedNodes add: candidate.
				]
			].
		]
	].

	^ order
]
