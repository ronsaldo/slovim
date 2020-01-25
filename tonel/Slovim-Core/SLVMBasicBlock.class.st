"
I represent a basic block in a function.
"
Class {
	#name : #SLVMBasicBlock,
	#superclass : #SLVMObject,
	#instVars : [
		'index',
		'postOrderIndex',
		'preOrderIndex',
		'name',
		'function',
		'firstInstruction',
		'lastInstruction',
		'numberOfInstructions',
		'predecessors',
		'successors',
		'immediateDominator',
		'dominanceFrontier',
		'backEdgesToMe',
		'structuredControlFlowHeader',
		'mergeBlock',
		'continueBlock',
		'unwindBlock',
		'unreachableSuccessors'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMBasicBlock >> accept: aVisitor [
	^ aVisitor visitBasicBlock: self
]

{ #category : #adding }
SLVMBasicBlock >> add: anInstruction [ 
	self addQuiet: anInstruction.
	self instructionAdded: anInstruction.
	^ anInstruction
]

{ #category : #adding }
SLVMBasicBlock >> add: anInstruction after: instructionPoint [
	instructionPoint ifNil: [ ^ self addFirst: anInstruction ].
	
	self assert: anInstruction previousInstruction isNil.
	self assert: anInstruction nextInstruction isNil.
	
	"Link the next"
	anInstruction nextInstruction: instructionPoint nextInstruction.
	anInstruction nextInstruction ifNotNil: [
		anInstruction nextInstruction previousInstruction: anInstruction
	] ifNil: [
		lastInstruction := anInstruction
	].

	"Link the previous"
	anInstruction previousInstruction: instructionPoint.
	instructionPoint nextInstruction: anInstruction.
	
	numberOfInstructions ifNotNil: [ numberOfInstructions := numberOfInstructions + 1 ].
	self instructionAdded: anInstruction.
	^ anInstruction
]

{ #category : #adding }
SLVMBasicBlock >> add: anInstruction before: instructionPoint [
	instructionPoint ifNil: [ ^ self addLast: instructionPoint ].
	
	self assert: anInstruction previousInstruction isNil.
	self assert: anInstruction nextInstruction isNil.
	
	"Link the previous"
	anInstruction previousInstruction: instructionPoint previousInstruction.
	anInstruction previousInstruction ifNotNil: [ 
		anInstruction previousInstruction nextInstruction: anInstruction
	] ifNil: [ 
		firstInstruction := anInstruction.
	].

	"Link the next"
	anInstruction nextInstruction: instructionPoint.
	instructionPoint previousInstruction: anInstruction.
	
	numberOfInstructions ifNotNil: [ numberOfInstructions := numberOfInstructions + 1].
	self instructionAdded: anInstruction.
	^ anInstruction
]

{ #category : #testing }
SLVMBasicBlock >> addBackEdgeToMe: aBackEdge [
	self assert: (predecessors includes: aBackEdge).
	backEdgesToMe := backEdgesToMe copyWith: aBackEdge
]

{ #category : #adding }
SLVMBasicBlock >> addFirst: anInstruction [
	self assert: anInstruction previousInstruction isNil.
	self assert: anInstruction nextInstruction isNil.
	firstInstruction ifNil: [
		firstInstruction := lastInstruction := anInstruction.
		numberOfInstructions := 1.
	] ifNotNil: [
		firstInstruction previousInstruction: anInstruction.
		anInstruction nextInstruction: firstInstruction.
		firstInstruction := anInstruction.
		numberOfInstructions ifNotNil: [ numberOfInstructions := numberOfInstructions + 1 ].
	].

	self instructionAdded: anInstruction.
	^ anInstruction
]

{ #category : #adding }
SLVMBasicBlock >> addInstructions: instructions after: insertionPoint [
	| currentPoint |
	currentPoint := insertionPoint.
	instructions do: [ :ins |
		self add: ins after: currentPoint.
		currentPoint := ins
	]
]

{ #category : #adding }
SLVMBasicBlock >> addInstructionsAfterAllocas: instructions [
	| before |
	before := firstInstruction.
	self allocaInstructionsDo: [ :alloca |
		before := alloca nextInstruction.
	].
	instructions do: [ :ins |
		self add: ins before: before
	]
]

{ #category : #adding }
SLVMBasicBlock >> addLast: anInstruction [
	^ self add: anInstruction
]

{ #category : #adding }
SLVMBasicBlock >> addPredecessor: aBasicBlock [
	(predecessors includes: aBasicBlock) ifFalse: [ 
		predecessors := predecessors copyWith: aBasicBlock
	]
	
]

{ #category : #adding }
SLVMBasicBlock >> addQuiet: anInstruction [ 
	self assert: anInstruction previousInstruction isNil.
	self assert: anInstruction nextInstruction isNil.
	lastInstruction ifNil: [
		anInstruction previousInstruction: nil.
		anInstruction nextInstruction: nil.
		firstInstruction := lastInstruction := anInstruction.
		numberOfInstructions := 1.
	]	ifNotNil: [
		lastInstruction nextInstruction: anInstruction.
		anInstruction previousInstruction: lastInstruction.
		lastInstruction := anInstruction.
		numberOfInstructions ifNotNil: [ numberOfInstructions := numberOfInstructions + 1 ].
	].

	anInstruction block: self.
	^ anInstruction
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> addUnreachableStructuredSuccessors [
	| changed |
	changed := false.
	unreachableSuccessors := #().
	(mergeBlock isNotNil and: [ mergeBlock predecessors isEmpty ]) ifTrue: [
		unreachableSuccessors := { mergeBlock }.
		changed := true.
	].

	(continueBlock isNotNil and: [ continueBlock predecessors isEmpty]) ifTrue: [
		unreachableSuccessors := unreachableSuccessors , { continueBlock }.
		changed := true.
	].

	(unwindBlock isNotNil and: [ unwindBlock predecessors isEmpty]) ifTrue: [
		unreachableSuccessors := unreachableSuccessors , { unwindBlock }.
		changed := true.
	].

	changed ifTrue: [ self computeSuccessors. ]
]

{ #category : #adding }
SLVMBasicBlock >> addWithName: anInstruction before: instructionPoint [
	anInstruction name ifNil: [ anInstruction name: function generateSymbol ].
	^ self add: anInstruction before: instructionPoint
]

{ #category : #accessing }
SLVMBasicBlock >> allInstructions [
	| result |
	result := OrderedCollection new.
	self instructionsDo: [ :instruction | result add: instruction ].
	^ result
]

{ #category : #enumerating }
SLVMBasicBlock >> allInstructionsDo: aBlock [
	self instructionsDo: [ :instruction |
		instruction allInstructionsDo: aBlock
	]
]

{ #category : #'as yet unclassified' }
SLVMBasicBlock >> allInstructionsMnemonics [
	"This is a method for facilitating the writing of some tests."
	^ self allInstructions collect: #mnemonic as: Array
]

{ #category : #enumerating }
SLVMBasicBlock >> allocaInstructionsDo: aBlock [
	self instructionsDo: [:ins |
		ins isAlloca ifFalse: [ ^ self ].
		aBlock value: ins
	]
]

{ #category : #'as yet unclassified' }
SLVMBasicBlock >> applySubstitutions: substitutionDictionary [
	structuredControlFlowHeader ifNotNil: [ structuredControlFlowHeader := substitutionDictionary at: structuredControlFlowHeader ].
	mergeBlock ifNotNil: [ mergeBlock := substitutionDictionary at: mergeBlock ].
	continueBlock ifNotNil: [ continueBlock := substitutionDictionary at: continueBlock ].
]

{ #category : #accessing }
SLVMBasicBlock >> backEdgesToMe [
	^ backEdgesToMe
]

{ #category : #accessing }
SLVMBasicBlock >> backEdgesToMe: anObject [
	backEdgesToMe := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> childrenNodes [
	^ Array streamContents: [ :out |
		self instructionsDo: [ :ins | out nextPut: ins ]
	]
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> clearPredecessorsFor: singlePredecessors [
	self assert: predecessors size = 1.
	self assert: predecessors first == singlePredecessors.
	predecessors := #()
	
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> clearUnreachableStructuredSuccessors [
	| changed oldUnreachableSuccessors|
	oldUnreachableSuccessors := unreachableSuccessors.
	changed := unreachableSuccessors isNotEmpty.
	unreachableSuccessors := #().

	changed ifTrue: [
		self computeSuccessors.
		oldUnreachableSuccessors do: [ :unreachable |
			unreachable clearPredecessorsFor: self.
		]
	]
]

{ #category : #adding }
SLVMBasicBlock >> computeLastInstruction [
	| current |
	current := lastInstruction := firstInstruction.
	[ current isNotNil ] whileTrue: [
		lastInstruction := current.
		current := current nextInstruction
	].
	
]

{ #category : #adding }
SLVMBasicBlock >> computeSuccessors [
	self isEmpty ifTrue: [ 
		successors := unreachableSuccessors
	] ifFalse: [
		successors := self lastInstruction successors , unreachableSuccessors.
	].

	successors do: [ :suc | suc addPredecessor: self]


]

{ #category : #'structured control flow' }
SLVMBasicBlock >> continueBlock [
	^ continueBlock
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> continueBlock: aBasicBlock [
	continueBlock ifNotNil: [ continueBlock structuredControlFlowHeader: nil ].
	continueBlock := aBasicBlock.
	continueBlock ifNotNil: [ continueBlock structuredControlFlowHeader: self ]
	
]

{ #category : #'as yet unclassified' }
SLVMBasicBlock >> copyingFrom: sourceBlock [
	"This is used for inlining. This is a quiet copy that does
	not preserve the structured control flow invariants."
	
	name := sourceBlock name.
	structuredControlFlowHeader := sourceBlock structuredControlFlowHeader.
	mergeBlock := sourceBlock mergeBlock.
	continueBlock := sourceBlock continueBlock.
]

{ #category : #accessing }
SLVMBasicBlock >> countNumberOfInstructions [
	| current |
	numberOfInstructions := 0.
	current := self firstInstruction.
	[current isNotNil] whileTrue: [
		current := current nextInstruction.
		numberOfInstructions := numberOfInstructions + 1.
	]
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> destroyStructuredCFGHeaderRole [
	self
		mergeBlock: nil;
		continueBlock: nil;
		clearUnreachableStructuredSuccessors.
]

{ #category : #accessing }
SLVMBasicBlock >> dominanceFrontier [
	^ dominanceFrontier
]

{ #category : #accessing }
SLVMBasicBlock >> dominanceFrontier: anObject [
	dominanceFrontier := anObject
]

{ #category : #testing }
SLVMBasicBlock >> dominates: anotherBlock [
	| position |
	position := anotherBlock immediateDominator.
	[ position ] whileNotNil: [
		position == self ifTrue: [ ^ true ].
		position := position immediateDominator
	].

	^ false
]

{ #category : #accessing }
SLVMBasicBlock >> firstInstruction [
	^ firstInstruction
]

{ #category : #printing }
SLVMBasicBlock >> fullPrintOn: aStream [
	aStream putIdentifier: self printString; nextPut: $:.
	aStream space.
	self printArray: predecessors on: aStream.
	aStream space.
	self printArray: successors on: aStream.
	unwindBlock ifNotNil: [ 
		aStream nextPutAll: ' unwindTo '; print: unwindBlock
	].
	aStream cr.
	self instructionsDo: [ :ins | aStream tab. ins fullPrintOn: aStream. aStream cr ]
]

{ #category : #accessing }
SLVMBasicBlock >> function [
	^ function
]

{ #category : #accessing }
SLVMBasicBlock >> function: anObject [
	function := anObject
]

{ #category : #printing }
SLVMBasicBlock >> gtTextViewIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite text
		title: 'Text';
		display: [ :node | node fullPrintString ]
]

{ #category : #printing }
SLVMBasicBlock >> gtTreeViewIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite tree 
		title: 'Nodes';
		display: [ :node | node ];
		children: [ :each | each childrenNodes];
		format: [ :node | node nodeTitle ]
]

{ #category : #testing }
SLVMBasicBlock >> hasPhiInstructions [
	^ self isEmpty not and: [ self firstInstruction isPhi ]
]

{ #category : #accessing }
SLVMBasicBlock >> immediateDominator [
	^ immediateDominator
]

{ #category : #accessing }
SLVMBasicBlock >> immediateDominator: anObject [
	immediateDominator := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> index [
	^ index
]

{ #category : #accessing }
SLVMBasicBlock >> index: anObject [
	index := anObject
]

{ #category : #initialization }
SLVMBasicBlock >> initialize [
	super initialize.
	predecessors := #().
	successors := #().
	unreachableSuccessors := #().
	backEdgesToMe := #().
]

{ #category : #adding }
SLVMBasicBlock >> instructionAdded: anInstruction [ 
	anInstruction block: self.
	anInstruction isTerminator ifTrue: [
		self computeSuccessors
	].
]

{ #category : #enumerating }
SLVMBasicBlock >> instructionAfterAllocas [
	| result |
	result := firstInstruction.
	[result isNotNil and: [result isAlloca]] whileTrue: [ 
		result := result nextInstruction
	].
	^ result
]

{ #category : #'successor sequences' }
SLVMBasicBlock >> instructionsDo: aBlock [
	| currentInstruction nextInstruction |
	currentInstruction := self firstInstruction.
	[ currentInstruction isNotNil ] whileTrue: [ 
		nextInstruction := currentInstruction nextInstruction.
		self assert: currentInstruction block == self.
		aBlock value: currentInstruction.
		currentInstruction := nextInstruction
	]
]

{ #category : #testing }
SLVMBasicBlock >> isBackEdgeToMe: aNode [
	^ backEdgesToMe includes: aNode
]

{ #category : #removing }
SLVMBasicBlock >> isCompletelyUnused [
	^ self isEmpty and: [ predecessors isEmpty and: [ successors isEmpty ] ]
]

{ #category : #testing }
SLVMBasicBlock >> isEmpty [
	^ firstInstruction isNil
]

{ #category : #testing }
SLVMBasicBlock >> isInstruction: instruction beforeThan: targetInstruction [
	| position |
	position := instruction.
	[ position ] whileNotNil: [ 
		position nextInstruction == targetInstruction ifTrue: [ ^ true ].
		position := position nextInstruction
	].
	^ false
]

{ #category : #testing }
SLVMBasicBlock >> isLastTerminator [
	^ self isEmpty not and: [ self lastInstruction isTerminator ]
]

{ #category : #testing }
SLVMBasicBlock >> isPartOfStructuredControlFlow [
	^ self isStructuredControlFlowDivergence or: [self isStructuredControlFlowMergeOrContinueBlock]
]

{ #category : #testing }
SLVMBasicBlock >> isStructuredControlFlowContinueBlock [
	^ structuredControlFlowHeader
		ifNil: [ false ]
		ifNotNil: [ structuredControlFlowHeader continueBlock == self ]
]

{ #category : #testing }
SLVMBasicBlock >> isStructuredControlFlowDivergence [
	^ mergeBlock isNotNil
]

{ #category : #testing }
SLVMBasicBlock >> isStructuredControlFlowLoop [
	^ continueBlock isNotNil
]

{ #category : #testing }
SLVMBasicBlock >> isStructuredControlFlowMergeBlock [
	^ structuredControlFlowHeader
		ifNil: [ false ]
		ifNotNil: [ structuredControlFlowHeader mergeBlock == self ]
]

{ #category : #testing }
SLVMBasicBlock >> isStructuredControlFlowMergeOrContinueBlock [
	^ structuredControlFlowHeader
		ifNil: [ false ]
		ifNotNil: [
			structuredControlFlowHeader mergeBlock == self or:
			[structuredControlFlowHeader continueBlock == self]]
]

{ #category : #testing }
SLVMBasicBlock >> isStructuredControlFlowSelection [
	^ mergeBlock isNotNil and: [continueBlock isNil]
]

{ #category : #accessing }
SLVMBasicBlock >> lastInstruction [
	^ lastInstruction
]

{ #category : #accessing }
SLVMBasicBlock >> livenessIndex [
	^ index
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> mergeBlock [
	^ mergeBlock
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> mergeBlock: aBasicBlock [
	mergeBlock ifNotNil: [ mergeBlock structuredControlFlowHeader: nil ].
	mergeBlock := aBasicBlock.
	mergeBlock ifNotNil: [ mergeBlock structuredControlFlowHeader: self ]
	
]

{ #category : #accessing }
SLVMBasicBlock >> name [
	^ name
]

{ #category : #accessing }
SLVMBasicBlock >> name: anObject [
	name := anObject
]

{ #category : #'as yet unclassified' }
SLVMBasicBlock >> nodeTitle [
	^ 'Basic block ' , self printString
]

{ #category : #accessing }
SLVMBasicBlock >> numberOfInstructions [
	numberOfInstructions ifNil: [ self countNumberOfInstructions ].
	^ numberOfInstructions
]

{ #category : #enumerating }
SLVMBasicBlock >> phiInstructionsDo: aBlock [
	self instructionsDo: [:ins |
		ins isPhi ifFalse: [ ^ self ].
		aBlock value: ins
	]
]

{ #category : #accessing }
SLVMBasicBlock >> postOrderIndex [
	^ postOrderIndex
]

{ #category : #accessing }
SLVMBasicBlock >> postOrderIndex: anObject [
	postOrderIndex := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> preOrderIndex [
	^ preOrderIndex
]

{ #category : #accessing }
SLVMBasicBlock >> preOrderIndex: anObject [
	preOrderIndex := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> predecessors [
	^ predecessors
]

{ #category : #adding }
SLVMBasicBlock >> predecessorsCouldBeRemoved [
	| oldPredecessors |
	oldPredecessors := predecessors.
	predecessors := #().
	oldPredecessors do: [ :pred |
		pred successors do: [ :succ | succ addPredecessor: pred ]
	]
]

{ #category : #printing }
SLVMBasicBlock >> printArray: anArray on: aStream [
	aStream nextPut: $[; space.
	anArray do: [ :el |
		 aStream print: el; space].
	aStream nextPut: $].
]

{ #category : #printing }
SLVMBasicBlock >> printOn: aStream [
	aStream nextPutAll: name; nextPut: $@; print: index
]

{ #category : #adding }
SLVMBasicBlock >> remove: anInstruction [
	(anInstruction previousInstruction isNil and: [ anInstruction nextInstruction isNil ]) ifTrue: [
		anInstruction block: nil.
		firstInstruction := lastInstruction := nil.
		numberOfInstructions := 0.
		^ self
	].

	anInstruction previousInstruction ifNil: [ 
		firstInstruction := anInstruction nextInstruction.
	] ifNotNil: [ 
		anInstruction previousInstruction nextInstruction: anInstruction nextInstruction
	].

	anInstruction nextInstruction ifNil: [
		lastInstruction := anInstruction previousInstruction.
	] ifNotNil: [ 
		anInstruction nextInstruction previousInstruction: anInstruction previousInstruction
	].

	anInstruction previousInstruction: nil.
	anInstruction nextInstruction: nil.
	anInstruction block: nil.
	numberOfInstructions ifNotNil: [numberOfInstructions := numberOfInstructions - 1].
]

{ #category : #adding }
SLVMBasicBlock >> removeChain: anInstructionChain [ 
	| current |
	current := anInstructionChain.
	[ current isNotNil ] whileTrue: [
		self assert: current block == self.
		current block: nil.
		current := current nextInstruction
	].
	
	anInstructionChain previousInstruction ifNil: [
		firstInstruction := lastInstruction := nil.
		numberOfInstructions := 0.
	] ifNotNil: [
		lastInstruction := anInstructionChain previousInstruction.
		lastInstruction nextInstruction: nil.
		anInstructionChain previousInstruction: nil.
		numberOfInstructions := nil.
	]
]

{ #category : #removing }
SLVMBasicBlock >> removeFromFunction [
	self assert: self isCompletelyUnused.
	function removeBasicBlock: self
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> removedUnreachableSuccessor: oldUnreachable [
	| oldUnreachableSuccessors|
	oldUnreachableSuccessors := unreachableSuccessors.
	unreachableSuccessors := oldUnreachableSuccessors copyWithout: oldUnreachable.

	oldUnreachableSuccessors	= unreachableSuccessors ifFalse: [ 
		self computeSuccessors.
		oldUnreachable clearPredecessorsFor: self.
	].
]

{ #category : #adding }
SLVMBasicBlock >> setChain: anInstructionChain [ 
	| current |
	numberOfInstructions := 0.
	firstInstruction := anInstructionChain.
	
	current := lastInstruction := anInstructionChain.
	[ current isNotNil ] whileTrue: [
		current block: self.
		lastInstruction := current.
		numberOfInstructions := numberOfInstructions + 1.
		current := current nextInstruction
	].
]

{ #category : #accessing }
SLVMBasicBlock >> size [
	| result |
	self flag: 'TODO: Add a cache for the size'.
	result := 0.
	self instructionsDo: [ :ins |
		result := result + 1
	].
	^ result
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> stealStructuredCFGHeaderFrom: otherBlock [
	| newMergeBlock newContinueBlock |
	self assert: self isStructuredControlFlowDivergence not.

	newMergeBlock := otherBlock mergeBlock.
	newContinueBlock := otherBlock continueBlock.
	unreachableSuccessors := otherBlock unreachableSuccessors.
	otherBlock
		mergeBlock: nil;
		continueBlock: nil;
		clearUnreachableStructuredSuccessors.

	self
		mergeBlock: newMergeBlock;
		continueBlock: newContinueBlock.

]

{ #category : #'structured control flow' }
SLVMBasicBlock >> stealStructuredCFGRoleFrom: otherBlock [
	| cfgHeader |
	self isPartOfStructuredControlFlow ifTrue: [ 
		self error: 'This block merging case is not yet supported.'
	].

	otherBlock isStructuredControlFlowDivergence ifTrue: [
		^ self stealStructuredCFGHeaderFrom: otherBlock
	].

	(otherBlock isStructuredControlFlowMergeBlock and: [ otherBlock isStructuredControlFlowContinueBlock ]) ifTrue: [
		self error: 'Invalid structured CFG detected'
	].

	cfgHeader := otherBlock structuredControlFlowHeader.
	otherBlock isStructuredControlFlowMergeBlock ifTrue: [
		cfgHeader
			mergeBlock: self;
			removedUnreachableSuccessor: otherBlock.
		^ self
	].

	otherBlock isStructuredControlFlowContinueBlock ifTrue: [
		cfgHeader
			continueBlock: self;
			removedUnreachableSuccessor: otherBlock.
		^ self
	].

	self error: 'This block merging case is not yet supported.'
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> structuredControlFlowHeader [
	^ structuredControlFlowHeader
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> structuredControlFlowHeader: aBasicBlock [
	(structuredControlFlowHeader isNotNil and: [aBasicBlock isNotNil]) ifTrue: [ 
		self assert: structuredControlFlowHeader == aBasicBlock
	].

	structuredControlFlowHeader := aBasicBlock
]

{ #category : #accessing }
SLVMBasicBlock >> successors [
	^ successors
]

{ #category : #accessing }
SLVMBasicBlock >> successors: anObject [
	successors := anObject
]

{ #category : #removing }
SLVMBasicBlock >> unreachablePredecessorRemoved: oldPredecessor [
	self predecessorsCouldBeRemoved.
	self assert: (predecessors includes: oldPredecessor) not.
	self phiInstructionsDo: [ :instruction |
		instruction incomingBlockRemoved: oldPredecessor
	]
]

{ #category : #'structured control flow' }
SLVMBasicBlock >> unreachableSuccessors [
	^ unreachableSuccessors
]

{ #category : #accessing }
SLVMBasicBlock >> unwindBlock [
	^ unwindBlock
]

{ #category : #accessing }
SLVMBasicBlock >> unwindBlock: anObject [
	unwindBlock := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> validImmediateDominator [
	function computeDominance.
	^ immediateDominator
]
