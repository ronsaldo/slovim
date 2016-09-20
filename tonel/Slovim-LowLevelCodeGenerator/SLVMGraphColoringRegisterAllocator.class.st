Class {
	#name : #SLVMGraphColoringRegisterAllocator,
	#superclass : #SLVMRegisterAllocator,
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #'as yet unclassified' }
SLVMGraphColoringRegisterAllocator >> allocateRegisters [
	| liveness graph |
	self buildAllocatableRegisterClasses: callingConvention allocatableRegisters.
	self buildScratchRegisterClasses: callingConvention scratchRegisters.
	liveness := SLVMLivenessAnalyzer analyze: function.
	
	graph := SLVMInterferenceGraphBuilder buildForLiveness: liveness.
	self allocateSpillLocations: graph
]

{ #category : #'graph coloring' }
SLVMGraphColoringRegisterAllocator >> allocateSpillLocations: interferenceGraph [
	| order usedColors usedCount stackFrame usedColorClasses spillClass compilationTarget temporariesWithClasses temporaries reusedIndex local |
	interferenceGraph nodes do: [ :node | node spillIndex: nil ].
	stackFrame := lirFunction stackFrame.
	order := self graphColoringOrdering: interferenceGraph.
	usedColorClasses := Dictionary new.
	temporariesWithClasses := Dictionary new.
	compilationTarget := lirFunction compilationTarget.
	
	order select: [:node | node variable isFunctionArgument not and: [ (node variable type size) > 0] ] thenDo: [ :node |
		spillClass := node spillClassForTarget: compilationTarget.
		usedColors := usedColorClasses at: spillClass ifAbsentPut: [ OrderedCollection new ].
		temporaries := temporariesWithClasses at: spillClass ifAbsentPut: [ OrderedCollection new ].
		usedColors atAllPut: false.
		usedCount := 0.

		node interferences do: [ :interference |
			((interference spillClassForTarget: compilationTarget) = spillClass and: [ interference spillIndex isNotNil ]) ifTrue: [
				(usedColors at: interference spillIndex) ifFalse: [ 
					usedColors at: interference spillIndex put: true.
					usedCount := usedCount + 1
				]
			]
		].
	
		usedCount = usedColors size ifTrue: [
			local := stackFrame createLocal: spillClass.
			node spillIndex: usedCount + 1.
			usedColors add: true.
			temporaries add: local.
			self mapSSA: node variable toSpillLocation: local.
		] ifFalse: [
			reusedIndex := usedColors findFirst: [:el | el == false].
			local := temporaries at: reusedIndex.
			node spillIndex: reusedIndex.
			self mapSSA: node variable toSpillLocation: local.
		]
	].

]

{ #category : #'graph coloring' }
SLVMGraphColoringRegisterAllocator >> graphColoringOrdering: interferenceGraph [
	self subclassResponsibility
]
