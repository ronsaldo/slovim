Class {
	#name : #SLVMOptPromoteAllocas,
	#superclass : #SLVMFunctionOptimizationPass,
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> addAggregatesThatUse: instruction except: toExclude intoPendingWorkList: pendingWork [
	| pointer variable |
	instruction instructionReferences do: [ :ref |
		(ref isStore and: [ ref value == instruction and: [ ref variable isInstruction ] ]) ifTrue: [ 
			"self halt."
			variable := nil.
			
			(ref variable isAlloca and: [ ref variable valueType isAggregateType ]) ifTrue: [
				variable := ref variable
			].
		
			ref variable isGetElementPointer ifTrue: [
				pointer := ref variable pointer.
				(pointer isInstruction and: [pointer isAlloca and: [pointer valueType isAggregateType ]]) ifTrue: [
					variable := pointer
				]
			].
		
			(variable ~~ nil and: [ variable ~~ toExclude ]) ifTrue: [
				pendingWork add: variable
			]
		]
	].

]

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
			"TODO: Replace this phi with undefined"
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
	undefinedInstruction := self undefinedFor: allocaInstruction valueType name: (function generateSymbol, allocaInstruction name) asSymbol.
	entryBlock addFirst: undefinedInstruction.
	definitionsPerNode at: entryBlock put: { undefinedInstruction }.
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
SLVMOptPromoteAllocas >> doPromoteAggregateConstant: alloca affected: affectedInstructions in: basicBlock pendingWork: pendingWork [
	| currentValue |
	currentValue := nil.
	basicBlock instructionsDo: [ :instruction | 
		affectedInstructions ifEmpty: [ ^ self ].
		(affectedInstructions includes: instruction) ifTrue: [
			affectedInstructions remove: instruction.
			instruction variable == alloca ifTrue: [
				instruction isLoad ifTrue: [
					self assert: currentValue isNotNil.
					self addAggregatesThatUse: instruction except: alloca intoPendingWorkList: pendingWork.
					instruction replaceWith: currentValue.
				].
				instruction isStore ifTrue: [
					currentValue := instruction value.
					self assert: currentValue isConstantStructureValue
				]
			] ifFalse: [
				self assert: instruction variable isGetElementPointer.
				instruction isLoad ifTrue: [
					self assert: currentValue isNotNil.
					self addAggregatesThatUse: instruction except: alloca intoPendingWorkList: pendingWork.
					instruction replaceWith: (currentValue slots at: instruction variable indices second value + 1)
				].
				instruction isStore ifTrue: [
					self assert: currentValue isConstantStructureValue.
					currentValue := currentValue copy.
					currentValue slots at: instruction variable indices second value + 1 put: instruction value
				]
			]
		]
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
	node predecessors ifEmpty: [ 
		"Undef"
		self halt
	] ifNotEmpty: [
		node predecessors size = 1 ifTrue: [ 
		^ self lastDefinitionValueAt: node predecessors first for: definitionsPerNode allocaInstruction: allocaInstruction
		].
	
		self assert: node predecessors size = 2.
		firstDefinition := self lastDefinitionValueAt: node predecessors first for: definitionsPerNode allocaInstruction: allocaInstruction.
		secondDefinition := self lastDefinitionValueAt: node predecessors second for: definitionsPerNode allocaInstruction: allocaInstruction.
		firstDefinition == secondDefinition ifTrue: [ ^ firstDefinition].
		self halt
		
	].

]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> isAggregateReferenceUsedForLoadingField: reference [
	| loadingPlaces |
	(reference hasConstantIndices and: [ reference indices first value = 0 ]) ifFalse: [ ^ false ].
		
	loadingPlaces := reference instructionReferences.
	loadingPlaces do: [ :p | p isLoad ifFalse: [^ false ] ].
	^ true
]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> isAllocaUsedForLoadingAggregateField: alloca [
	| references expectedPreviousInstruction |
	references := alloca instructionReferences.
	references size < 2 ifTrue: [ ^ false ].
	(references first isStore and: [ references second isGetElementPointer ]) ifFalse: [ ^ false ].

	expectedPreviousInstruction := references first.
	references allButFirstDo: [ :ref |
		ref previousInstruction == expectedPreviousInstruction ifFalse: [ ^ false ].
		(self isAggregateReferenceUsedForLoadingField: ref) ifFalse: [ ^ false ].
		expectedPreviousInstruction := ref
	].

	^ true
]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> isValidActionForAggregateConstant: instruction of: aggregate [
	| indices |
	instruction isStore ifTrue: [ ^ instruction value isConstantStructureValue ].
	instruction isLoad ifTrue: [ ^ true ].
	instruction isGetElementPointer ifTrue: [
		indices := instruction indices.
		indices size ~= 2 ifTrue: [ ^ false ].
		indices first isConstantValue ifFalse: [ ^ false ].
		indices first value = 0 ifFalse: [ ^ false ].
		indices second isConstantValue ifFalse: [ ^ false ].
		
		instruction instructionReferences do: [ :ref |
			(ref isLoad or: [ref isStore]) ifFalse: [ ^ false ].
			ref isStore ifTrue: [
				(ref value isConstant or:
				[ref value isInstruction and: [ ref value isLoad and: [ aggregate instructionReferences includes: (ref value variable) ] ] ]) ifFalse: [ ^ false ] ].
		].
	
		^ true
	].

	^ false
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
	self promoteAggregatesOn: aFunction.
	
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
		undefined := self undefinedFor: allocaInstruction valueType name: allocaInstruction name.
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

]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> promoteAggregate: alloca pendingWork: pendingWork [
	alloca valueType isAggregateType ifFalse: [ ^ self ].
	alloca instructionReferences ifEmpty: [ ^ self ].
	
	(self promoteAggregateConstant: alloca pendingWork: pendingWork) ifTrue: [ ^ self ].
	(self tryToSplitLocalOnlyAggregate: alloca) ifTrue: [ ^ self ].

	(self isAllocaUsedForLoadingAggregateField: alloca) ifTrue: [
		^ self promoteAllocaForLoadingAggregateField: alloca
	].

]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> promoteAggregateConstant: alloca pendingWork: pendingWork [
	| references basicBlock affectedInstructions |
	references := alloca instructionReferences.
	references first isStore ifFalse: [ ^ false ].

	basicBlock := references first block.
	references do: [ :ref | 
		self flag: 'TODO: Support multiple basic blocks.'.
		ref block ~~ basicBlock ifTrue: [ ^ false ].
		(self isValidActionForAggregateConstant: ref of: alloca) ifFalse: [ ^ false ]
	].

	"(alloca function hasSelectorAndClassBinding and: [alloca function selectorValue = #computeTransformationInto:]) ifTrue: [ self halt ]."

	"Compute the set of affected instructions."
	affectedInstructions := IdentitySet new.
	references do: [ :ref | 
		ref isGetElementPointer ifTrue: [
			affectedInstructions addAll: ref instructionReferences
		] ifFalse: [
			affectedInstructions add: ref.
		]
	].

	self doPromoteAggregateConstant: alloca affected: affectedInstructions in: basicBlock pendingWork: pendingWork.

	alloca removeFromBlockWithAllReferences.
	^ true
]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> promoteAggregatesOn: aFunction [
	| pendingWork toProcess |
	pendingWork := IdentitySet new.
	
	aFunction basicBlocks first allocaInstructionsDo: [ :alloca |
		alloca valueType isAggregateType ifTrue: [ pendingWork add: alloca ]
	].

	[ pendingWork isNotEmpty ] whileTrue: [ 
		toProcess := pendingWork anyOne.
		pendingWork remove: toProcess.
		self promoteAggregate: toProcess pendingWork: pendingWork
	]
]

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> promoteAllocaForLoadingAggregateField: alloca [
	| references loadingPlaces aggregateValue indices fieldValue store |
	references := alloca instructionReferences.
	store := references first.
	self assert: store isStore.
	aggregateValue := references first value.
	
	references allButFirstDo: [ :gep |
		self assert: gep isGetElementPointer.
		indices := gep indices allButFirst collect: #value.
	
		loadingPlaces := references second instructionReferences.
		loadingPlaces do: [ :fieldLoadPlace | 
			self assert: fieldLoadPlace isLoad.
			fieldValue := SLVMExtractValue aggregate: aggregateValue indices: indices.
			fieldValue name: fieldLoadPlace name. 
			fieldLoadPlace block add: fieldValue before: fieldLoadPlace.
			fieldLoadPlace replaceWith: fieldValue
		].

		gep removeFromBlock.
	].

	store removeFromBlock.
	alloca removeFromBlock
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

{ #category : #'aggregate promotion' }
SLVMOptPromoteAllocas >> tryToSplitLocalOnlyAggregate: alloca [
	| references refIndices |
	references := alloca instructionReferences.
	
	references do: [ :ref |
		ref isGetElementPointer ifFalse: [ ^ false ].
		
		refIndices := ref indices.
		refIndices first isConstantValue ifFalse: [ ^ false ].
		refIndices first value = 0 ifFalse: [ ^ false ].
		refIndices second isConstantValue ifFalse: [ ^ false ].

		ref instructionReferences do: [ :loadOrStore |
			(loadOrStore isLoad or: [loadOrStore isStore]) ifFalse: [ ^ false ]
		]
	].

	self halt.

	^ true
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> undefinedFor: type name: instructionName [
	"type isDynamicObjectType ifTrue: [ ^ SLVMConstantValue type: type value: nil ]."
	^ (SLVMUndefined type: type) name: instructionName
]
