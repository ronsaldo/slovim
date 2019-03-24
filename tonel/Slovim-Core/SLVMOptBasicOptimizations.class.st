Class {
	#name : #SLVMOptBasicOptimizations,
	#superclass : #SLVMFunctionOptimizationPass,
	#instVars : [
		'pendingWork'
	],
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #private }
SLVMOptBasicOptimizations >> foldBranchAtBlock: block [
	| branch jump destinations discardedBranch branchBlock mergeBlock |
	branch := block lastInstruction.
	self assert: branch isBranch.
	
	branch condition isConstantValue ifFalse: [ ^ self ].

	branchBlock := branch block.
	
	self flag: 'TODO: Support the destruction of loops.'.
	branchBlock continueBlock ifNotNil: [ ^ self ].
	
	mergeBlock := branch block mergeBlock.
	
	self assert: branchBlock isStructuredControlFlowDivergence.
	self assert: mergeBlock isStructuredControlFlowMergeBlock.
	branchBlock destroyStructuredCFGHeaderRole.

	self assert: branchBlock isStructuredControlFlowDivergence not.
	self assert: mergeBlock isStructuredControlFlowMergeBlock not.

	discardedBranch := nil.
	branch condition value ifTrue: [ 
		jump := SLVMJump destination: branch trueBlock.
		discardedBranch := branch falseBlock
	] ifFalse: [
		jump := SLVMJump destination: branch falseBlock.
		discardedBranch := branch trueBlock
	].

	destinations := {branch trueBlock . branch falseBlock}.
	branch removeFromBlock.
	block add: jump.
	
	destinations do: #predecessorsCouldBeRemoved.

	pendingWork
		add: block;
		add: discardedBranch

]

{ #category : #'as yet unclassified' }
SLVMOptBasicOptimizations >> foldConstant: instruction [
	| folded |
	folded := instruction foldConstant.
	folded ~~ instruction ifTrue: [
		(folded isInstruction and: [ folded block isNil ]) ifTrue: [
			instruction block addWithName: folded before: instruction
		].
	
		instruction instructionReferences do: [ :ref |
			ref isInstruction ifTrue: [ pendingWork add: ref block ]
		].
	
		instruction replaceWith: folded.
	].

]

{ #category : #private }
SLVMOptBasicOptimizations >> mergeWithNextBlockOf: block [
	| removedBlock function removedInstruction cfgMergeWhitelisted |
	function := block function.
	removedBlock := block lastInstruction destination.

	"Sanity checks"
	removedBlock == block ifTrue: [  ^ self ].
	removedBlock predecessors size ~= 1 ifTrue: [
		self flag: 'TODO: If I only have one instruction, the jump then this could be safe to merge'.
		^ self
	].

	self assert: removedBlock predecessors first == block.
	self assert: removedBlock function == block function.

	"Never merge into continue blocks"
	removedBlock isStructuredControlFlowContinueBlock ifTrue: [ ^ self ].
	
	"CFG part , CFG part. This requires white listing"
	(block isPartOfStructuredControlFlow and: [ removedBlock isPartOfStructuredControlFlow ]) ifTrue: [ 		cfgMergeWhitelisted := false.
		cfgMergeWhitelisted ifFalse: [ ^ self ]
	].

	removedBlock phiInstructionsDo: [ :phi |
		self assert: phi parameters size = 1.
		self assert: phi incomingBlocks first == block.
		phi replaceWith: phi parameters first
	].
	
	block lastInstruction removeFromBlock.
	removedInstruction := OrderedCollection new.
	removedBlock instructionsDo: [:ins | removedInstruction add: ins].
	
	removedBlock instructionsDo: [ :instruction |
		removedBlock remove: instruction.
		block addLast: instruction
	].
	
	removedBlock isPartOfStructuredControlFlow ifTrue: [ 
		block stealStructuredCFGRoleFrom: removedBlock.
	].

	block computeSuccessors.
	removedBlock computeSuccessors; predecessorsCouldBeRemoved.
	block successors do: #predecessorsCouldBeRemoved.
		
	block successors do: [ :succ |
		succ phiInstructionsDo: [ :phi | phi replaceParent: removedBlock with: block ]
	].
			
	self assert: removedBlock isCompletelyUnused.
	self assert: (block successors includes: removedBlock) not.
	removedBlock removeFromFunction.
	pendingWork add: block.
	self validateFunction: function.
]

{ #category : #applying }
SLVMOptBasicOptimizations >> passOnFunction: aFunction [
	| work |
	pendingWork ifNil: [ pendingWork := Set new ].
	pendingWork addAll: aFunction basicBlocks.
	[ pendingWork isNotEmpty ] whileTrue: [ 
		work := pendingWork anyOne.
		pendingWork remove: work.
		
		self processBlock: work.
	]
]

{ #category : #private }
SLVMOptBasicOptimizations >> processBlock: block [
	| oldSuccessors function seenInstructions |
	function := block function.
	function ifNil: [ ^ self ].
	
	(block ~~ function basicBlocks first and: [ block predecessors isEmpty ]) ifTrue: [ 
		block isEmpty ifTrue: [
			function removeBasicBlock: block.
			self validateFunction: function.
			^ self
		].
	
		"Remove the unreachable block"
		oldSuccessors := block successors copy.
		block lastInstruction removeFromBlock.
		block successors: #().
		oldSuccessors do: [:s | s unreachablePredecessorRemoved: block].
		
		function removeBasicBlock: block.
		pendingWork addAll: oldSuccessors.
		oldSuccessors do: [ :succ | pendingWork addAll: succ predecessors ].
		self validateFunction: function.
		^ self
	].

	block isEmpty ifTrue: [
		self validateFunction: function.
		^ self
	].
	
	seenInstructions := Dictionary new.
	block instructionsDo: [ :instruction |
		self processInstruction: instruction seenInstructions: seenInstructions
	].
	self validateFunction: function.

	(block lastInstruction isJump) ifTrue: [
		self mergeWithNextBlockOf: block
	] ifFalse: [
		(block lastInstruction isBranch) ifTrue: [ 
			self foldBranchAtBlock: block.
			self validateFunction: function.
		] ifFalse: [
			self validateFunction: function.
		]
	]
]

{ #category : #'as yet unclassified' }
SLVMOptBasicOptimizations >> processInstruction: instruction seenInstructions: seenInstructions [
	| signature |
	self removeDeadPureInstructions: instruction.
	instruction block ifNil: [ ^ self ].
	
	self foldConstant: instruction.
	instruction block ifNil: [ ^ self ].

	"Remove duplicated pure instructions."
	instruction isPureInstruction ifTrue: [ 
		signature := instruction signature.
		seenInstructions at: signature ifPresent: [ :previous |
			previous block ifNotNil: [ 
				instruction replaceWith: previous
			]
		 ] ifAbsentPut: [ instruction ]
	]
	
]

{ #category : #'as yet unclassified' }
SLVMOptBasicOptimizations >> pureDeadInstructionCondition: instruction [
	^ instruction isPureInstruction and: [ instruction hasReferences not ]
]

{ #category : #'as yet unclassified' }
SLVMOptBasicOptimizations >> removeDeadPureInstructions: instruction [
	| pendingInstructions currentInstruction |
	(self pureDeadInstructionCondition: instruction) ifFalse: [ ^ self ].
	
	pendingInstructions := Set with: instruction.
	[ pendingInstructions isNotEmpty ] whileTrue: [
		currentInstruction := pendingInstructions anyOne.
		pendingInstructions remove: currentInstruction.
		
		(self pureDeadInstructionCondition: currentInstruction) ifTrue: [
			currentInstruction parameters select: #isInstruction thenDo: [ :ins | pendingInstructions add: ins ].
			currentInstruction removeFromBlock
		]
	]
]
