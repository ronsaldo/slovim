Class {
	#name : #SLVMOptPromoteAllocas,
	#superclass : #SLVMFunctionOptimizationPass,
	#instVars : [
		'currentFunction',
		'undefinedInsertionPoint'
	],
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> addPhi: phi previousDefinitions: definitionsPerNode allocaInstruction: alloca [
	| value shouldBeRemoved definitions phiBlock |
	phi block predecessors do: [ :predecessor |
		value := self lastDefinitionValueAt: predecessor for: definitionsPerNode allocaInstruction: alloca forPhiNode: true.
		value ifNotNil: [ 
			phi addValue: value from: predecessor
		]
	].

	shouldBeRemoved := false.
	phiBlock := phi block.
	self assert: phi parameters isNotEmpty.
	self assert: phi parameters size = phi block predecessors size.
	
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
	undefinedInstruction := self undefinedFor: allocaInstruction valueType name: function generateSymbol.

	entryBlock := undefinedInsertionPoint block.
	entryBlock add: undefinedInstruction before: undefinedInsertionPoint.
	(definitionsPerNode at: entryBlock ifAbsentPut: [ OrderedCollection new ])
		addFirst: undefinedInstruction.
	^ undefinedInstruction
]

{ #category : #testing }
SLVMOptPromoteAllocas >> canBePromoted: allocaInstruction [
	allocaInstruction instructionReferences do: [ :ref |
		((ref isLoad or: [ ref isStore ]) and: [ ref volatile ]) ifTrue: [ ^ false ].
		(ref isLoad not and: [ ref isStore not ]) ifTrue: [ ^ false ]
	].

	^ true
]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> doPromoteLocalAggregate: alloca access: access previousIndices: previousIndices [
	| newIndices block load insertValue store extractValue |
	block := access block.
	access isLoad ifTrue: [
		self assert: access volatile not.
		previousIndices ifEmpty: [ ^ self ].

		load := block addWithName: (SLVMLoadInstruction variable: alloca) before: access.
		extractValue := block addWithName: (SLVMExtractValue aggregate: load indices: previousIndices) before: access.
		access replaceWith: extractValue.
		^ self.
	].

	access isStore ifTrue: [
		self assert: access volatile not.
		previousIndices ifEmpty: [ ^ self ].
		
		load := block addWithName: (SLVMLoadInstruction variable: alloca) before: access.
		insertValue := block addWithName: (SLVMInsertValue aggregate: load value: access value indices: previousIndices) before: access.
		store := block addWithName: (SLVMStoreInstruction value: insertValue variable: alloca) before: access..
		access removeFromBlock.
		^ self.
	].

	access isGetElementPointer ifTrue: [
		self assert: access isInBounds.
		newIndices := previousIndices , access aggregateInBoundIndices.
		self doPromoteLocalAggregate: alloca accessesFromPointer: access previousIndices: newIndices.
		access removeFromBlock.
		^ self.
	].

	self error: 'Should not get here'
]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> doPromoteLocalAggregate: alloca accessesFromPointer: pointer previousIndices: previousIndices [
	pointer instructionReferences copy do: [ :access |
		self doPromoteLocalAggregate: alloca access: access previousIndices: previousIndices
	]
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

{ #category : #accessing }
SLVMOptPromoteAllocas >> firstDefinitionValueAt: node for: definitionsPerNode allocaInstruction: allocaInstruction [
	| firstDefinition secondDefinition |
	definitionsPerNode at: node ifPresent: [ :definitions |
		definitions first isPhi ifTrue: [ 
			^ definitions first
		].
	].

	self assert: node predecessors size <= 2.
	self assert: node predecessors isNotEmpty.

	node predecessors size = 1 ifTrue: [ 
		^ self lastDefinitionValueAt: node predecessors first for: definitionsPerNode allocaInstruction: allocaInstruction
	].
	
	self assert: node predecessors size = 2.
	firstDefinition := self lastDefinitionValueAt: node predecessors first for: definitionsPerNode allocaInstruction: allocaInstruction.
	secondDefinition := self lastDefinitionValueAt: node predecessors second for: definitionsPerNode allocaInstruction: allocaInstruction.
	self flag: 'FIXME: Why is this case even possible?'.
	firstDefinition == secondDefinition ifTrue: [ ^ firstDefinition].
	self halt
]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> isAggregateReferenceUsedForLoadingField: reference [
	| loadingPlaces |
	reference hasConstantInBoundsIndices ifFalse: [ ^ false ].
		
	loadingPlaces := reference instructionReferences.
	loadingPlaces do: [ :p | p isLoad ifFalse: [^ false ] ].
	^ true
]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> isValidInstructionForLocalOnlyAggregate: instruction [
	(instruction isLoad or: [ instruction isStore ]) ifTrue: [ 
		^ instruction volatile not.
	].

	instruction isGetElementPointer ifFalse: [ ^ false ].
	instruction hasConstantInBoundsIndices ifFalse: [ ^ false ].
	instruction instructionReferences do: [ :memberAccess |
		(self isValidInstructionForLocalOnlyAggregate: memberAccess) ifFalse: [ ^ false ]
	].

	^ true
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

	self assert: currentNode isNotNil.
	instructionResult := (definitionsPerNode at: currentNode) last.
	^ instructionResult isStore ifTrue: [ instructionResult value ] ifFalse: [ instructionResult ]
]

{ #category : #accessing }
SLVMOptPromoteAllocas >> lastDefinitionValueAtLoad: loadInstruction for: definitionsPerNode allocaInstruction: allocaInstruction [
	| loadNode definitions lastStore |
	loadNode := loadInstruction block.
	definitions := definitionsPerNode at: loadNode ifAbsent: [
		^ self lastDefinitionValueAt: loadNode for: definitionsPerNode allocaInstruction: allocaInstruction
	].

	(definitions size = 1 and: [ definitions first isPhi ]) ifTrue: [ ^ definitions first ].
	
	lastStore := self findLastStoreTo: allocaInstruction before: loadInstruction.
	lastStore ifNil: [ ^ self firstDefinitionValueAt: loadNode for: definitionsPerNode allocaInstruction: allocaInstruction ].
	^ lastStore value
]

{ #category : #applying }
SLVMOptPromoteAllocas >> passOnFunction: aFunction [
	| toBePromoted |
	aFunction isEmpty ifTrue: [ ^ self ].
	currentFunction := aFunction.
	self promoteAggregates.
	
	toBePromoted := OrderedCollection new.
	undefinedInsertionPoint := aFunction basicBlocks first firstInstruction.
	aFunction basicBlocks first instructionsDo: [ :ins |
		ins isAlloca ifTrue: [
			undefinedInsertionPoint := ins nextInstruction.
			(self canBePromoted: ins) ifTrue: [ 
				toBePromoted add: ins
			].
		].
		
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
			(definitionsPerNode at: ref block ifAbsentPut: [ OrderedCollection new ])
				add: ref
		].
	].

	(hasLoad not) ifTrue: [
		"This variable is not used"
		allocaInstruction instructionReferences asArray do: [:each | each removeFromBlock].
		allocaInstruction removeFromBlock.
		^ self
	].

	(hasStore not) ifTrue: [
		"This variable is never set. It always contains the undefined value."
		undefined := self undefinedFor: allocaInstruction valueType name: allocaInstruction name.
		undefinedInsertionPoint block add: undefined before: undefinedInsertionPoint.
		allocaInstruction instructionReferences asArray do: [ :load |
			load replaceWith: undefined.
		].
	
		allocaInstruction removeFromBlock.
		^ self
	].

	"Make sure the variable is at least undefined on the entry block."
	undefined := self addUndefinedTo: definitionsPerNode allocaInstruction: allocaInstruction.

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
				phiNode := (SLVMPhi type: allocaInstruction valueType) name: (allocaInstruction block function generateSymbol, allocaInstruction name) asSymbol.
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
	
	"Replace the loads, then remove the stores."
	allocaInstruction instructionReferences asArray do: [ :ref |
		ref isLoad ifTrue: [
			loadValue := self lastDefinitionValueAtLoad: ref for: definitionsPerNode allocaInstruction: allocaInstruction.
			ref replaceWith: loadValue.
		].
	].

	allocaInstruction instructionReferences asArray do: [ :ref |
		ref isStore ifTrue: [
			ref removeFromBlock
		].
	].

	allocaInstruction removeFromBlock.
	"Remove the unused undefined instruction"
	undefined hasReferences ifFalse: [
		undefined removeFromBlock
	]

]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> promoteAggregates [
	currentFunction basicBlocks first allocaInstructionsDo: [ :alloca |
		alloca valueType isAggregateType ifTrue: [ self promoteLocalAggregate: alloca ]
	].

]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> promoteLocalAggregate: alloca [
	alloca instructionReferences do: [ :ref |
		(self isValidInstructionForLocalOnlyAggregate: ref) ifFalse: [ ^ self ]
	].

	self doPromoteLocalAggregate: alloca accessesFromPointer: alloca previousIndices: #().
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

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> undefinedFor: type name: instructionName [
	"type isDynamicObjectType ifTrue: [ ^ SLVMConstantValue type: type value: nil ]."
	^ (SLVMConstantUndefined type: type) name: instructionName
]
