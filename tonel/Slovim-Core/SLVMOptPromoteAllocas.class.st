Class {
	#name : #SLVMOptPromoteAllocas,
	#superclass : #SLVMFunctionOptimizationPass,
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> addPhi: phi previousDefinitions: definitionsPerNode allocaInstruction: alloca [
	| value shouldBeRemoved definitions phiBlock |
	phi block predecessors do: [ :predecessor |
		value := self lastDefinitionValueAt: predecessor for: definitionsPerNode allocaInstruction: alloca forPhiNode: true.
		(value isNotNil and: [ value isUndefined not ]) ifTrue: [ 
			phi addValue: value from: predecessor
		]
	].

	shouldBeRemoved := false.
	phiBlock := phi block.
	phi parameters isEmpty ifTrue: [ 
		phi instructionReferences isEmpty ifTrue: [
			phi removeFromBlock 
		] ifFalse: [
			self halt.
		].
	
		shouldBeRemoved := true.	
	].

	(phi parameters size = 1) ifTrue: [
		phi instructionReferences isEmpty ifTrue: [
			phi removeFromBlock 
		] ifFalse: [
			self assert: phi parameters first ~~ phi.
			phi replaceWith: phi parameters first.
		].
	
		shouldBeRemoved := true.
	].
	
	shouldBeRemoved ifTrue: [
		definitions := definitionsPerNode at: phiBlock.
		definitions removeFirst.
		definitions ifEmpty: [
			definitionsPerNode removeKey: phiBlock
		].
	].

]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> addUndefinedTo: definitionsPerNode allocaInstruction: allocaInstruction [
	| function entryBlock undefinedInstruction |
	function := allocaInstruction block function.
	entryBlock := function basicBlocks first.
	undefinedInstruction := (SLVMUndefined type: allocaInstruction valueType) name: (allocaInstruction name , function generateSymbol) asSymbol.
	entryBlock addFirst: undefinedInstruction.
	definitionsPerNode at: entryBlock put: { undefinedInstruction }.
	^ undefinedInstruction
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> canBePromoted: allocaInstruction [
	allocaInstruction instructionReferences do: [ :ref |
		(ref isLoad not and: [ ref isStore not ]) ifTrue: [ ^ false ]
	].

	^ true
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> findLastStoreTo: allocaInstruction before: loadInstruction [
	| currentInstruction |
	currentInstruction := loadInstruction previousInstruction.
	[ currentInstruction isNotNil ] whileTrue: [
		(currentInstruction isStore and: [ currentInstruction variable == allocaInstruction ]) ifTrue: [
			^ currentInstruction
		].
		currentInstruction := currentInstruction previousInstruction.
	].

	^ nil

]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> lastDefinitionValueAt: node for: definitionsPerNode allocaInstruction: alloca [
	^ self lastDefinitionValueAt: node for: definitionsPerNode allocaInstruction: alloca forPhiNode: false
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> lastDefinitionValueAt: node for: definitionsPerNode allocaInstruction: alloca forPhiNode: isForPhiNode [
	| currentNode instructionResult |
	currentNode := node.
	[ currentNode isNotNil and: [ (definitionsPerNode includesKey: currentNode) not ] ] whileTrue: [ 
		currentNode := currentNode immediateDominator
	].

	"Did we find a definition"
	currentNode isNil ifTrue: [
		isForPhiNode ifTrue: [ ^ nil ].
		^ self addUndefinedTo: definitionsPerNode allocaInstruction: alloca
	].

	instructionResult := (definitionsPerNode at: currentNode) last.
	^ instructionResult isStore ifTrue: [ instructionResult value ] ifFalse: [ instructionResult ]
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> lastDefinitionValueAtLoad: loadInstruction for: definitionsPerNode allocaInstruction: allocaInstruction [
	| loadNode definitions lastStore |
	loadNode := loadInstruction block.
	definitions := definitionsPerNode at: loadNode ifAbsent: [
		^ self lastDefinitionValueAt: loadNode for: definitionsPerNode allocaInstruction: allocaInstruction
	].

	(definitions size = 1 and: [ definitions first isPhi ]) ifTrue: [ ^ definitions first ].
	
	lastStore := self findLastStoreTo: allocaInstruction before: loadInstruction.
	(lastStore isNil and: [ definitions first isPhi ]) ifTrue: [ ^ definitions ].
	
	lastStore ifNil: [ ^ self lastDefinitionValueAt: loadNode for: definitionsPerNode allocaInstruction: allocaInstruction ].
	^ lastStore value
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> passOnFunction: aFunction [
	| toBePromoted |
	toBePromoted := OrderedCollection new.
	aFunction basicBlocks first instructionsDo: [ :ins |
		(ins isAlloca and: [self canBePromoted: ins]) ifTrue: [ 
			toBePromoted add: ins
		]
	].

	aFunction computeDominance.
	toBePromoted do: [ :alloca | self promote: alloca ]
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> promote: allocaInstruction [
	| hasLoad hasStore pendingWork workNode phiNodeDictionary phiNode definitionsPerNode originalDefinitionSites loadValue undefined |
	definitionsPerNode := Dictionary new.
	
	hasLoad := false.
	hasStore := false.
	allocaInstruction instructionReferences do: [ :ref |
		ref isLoad ifTrue: [ hasLoad := true ].
		ref isStore ifTrue: [
			hasStore := true.
			(definitionsPerNode at: ref block ifAbsentPut: [ OrderedCollection new. ])
				add: ref
		].
	].

	(hasLoad not) ifTrue: [
		"This variable is not used"
		allocaInstruction instructionReferences asArray do: #removeFromBlock.
		allocaInstruction removeFromBlock.
		^ self
	].

	(hasStore not) ifTrue: [
		"This variable is never set. It always contains the undefined value."
		undefined := (SLVMUndefined type: allocaInstruction valueType) name: allocaInstruction name.
		allocaInstruction block function basicBlocks addFirst: undefined.  
		allocaInstruction instructionReferences asArray do: [ :load |
			load replaceWith: undefined.
		].
	
		allocaInstruction removeFromBlock.
		^ self
	].

	"Gather the basic blocks with the definitions."
	originalDefinitionSites := Set new.
	definitionsPerNode keysDo: [ :node | originalDefinitionSites add: node ].
	pendingWork := originalDefinitionSites asOrderedCollection .
	
	phiNodeDictionary := Dictionary new.
	[ pendingWork isEmpty ] whileFalse: [ 
		workNode := pendingWork last.
		pendingWork removeLast.
		
		workNode dominanceFrontier do: [ :frontierNode |
			phiNodeDictionary at: frontierNode ifAbsentPut: [
				phiNode := (SLVMPhi type: allocaInstruction valueType) name: (allocaInstruction name , allocaInstruction block function generateSymbol) asSymbol.
				frontierNode addFirst: phiNode.
				(definitionsPerNode at: frontierNode ifAbsentPut: [ OrderedCollection new. ])
					add: phiNode.

				(originalDefinitionSites includes: frontierNode) ifFalse: [ 
					pendingWork add: frontierNode.
				].
				phiNode
			]
		]
	].

	"Sort the definitions per node."
	definitionsPerNode keysAndValuesDo: [ :node :definitions | self sortNode: node definitions: definitions allocaInstruction: allocaInstruction ].

	"Finish the phi nodes."
	phiNodeDictionary valuesDo: [ :phi | self addPhi: phi previousDefinitions: definitionsPerNode allocaInstruction: allocaInstruction ].
	
	"Replace the loads and remove the stores."
	allocaInstruction instructionReferences asArray do: [ :ref |
		ref isLoad ifTrue: [
			loadValue := self lastDefinitionValueAtLoad: ref for: definitionsPerNode allocaInstruction: allocaInstruction.
			ref replaceWith: loadValue.
		].
		ref isStore ifTrue: [
			ref removeFromBlock
		].
	].

	allocaInstruction removeFromBlock.

]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> sortNode: node definitions: definitions allocaInstruction: allocaInstruction [
	| lastStore |
	definitions size <= 1 ifTrue: [ ^ self ].

	"Move the phi node to the begining."
	definitions last isPhi ifTrue: [ definitions swap: definitions size with: 1 ].
	
	"Find the last store"
	lastStore := nil.
	node instructionsDo: [ :instruction |
		(instruction isStore and: [ instruction variable == allocaInstruction ]) ifTrue: [ 
			lastStore := instruction
		]
	].
	self assert: lastStore isNotNil.
	
	definitions swap: (definitions indexOf: lastStore) with: definitions size.
]
