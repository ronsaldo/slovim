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
	| branch jump destinations discardedBranch |
	branch := block lastInstruction.
	self assert: branch isBranch.
	
	branch condition isConstantValue ifFalse: [ ^ self ].
	discardedBranch := nil.
	branch condition value ifTrue: [ 
		jump := SLVMJump destination: branch trueBlock.
		discardedBranch := branch falseBlock
	] ifFalse: [
		jump := SLVMJump destination: branch falseBlock.
		discardedBranch := branch trueBlock
	].

	jump mergeBlock: branch mergeBlock; continueBlock: branch continueBlock.
	destinations := {branch trueBlock . branch falseBlock}.
	branch removeFromBlock.
	block add: jump.
	
	destinations do: #predecessorsCouldBeRemoved.
	jump addUnreachableSuccessors.
	
	pendingWork add: discardedBranch.
	self mergeWithNextBlockOf: block.
]

{ #category : #'as yet unclassified' }
SLVMOptBasicOptimizations >> foldConstant: instruction [
	| folded |
	folded := instruction foldConstant.
	folded ~~ instruction ifTrue: [
		instruction instructionReferences do: [ :ref |
			ref isInstruction ifTrue: [ pendingWork add: ref block ]
		].
	
		instruction replaceWith: folded.
	].

]

{ #category : #private }
SLVMOptBasicOptimizations >> mergeWithNextBlockOf: block [
	| removedBlock function removedInstruction |
	function := block function.
	removedBlock := block lastInstruction destination.
	(removedBlock == block or: [ removedBlock predecessors size ~= 1 ]) ifTrue: [  ^ self ].
	self assert: removedBlock predecessors first == block.
	self assert: removedBlock function == block function.
	
	block lastInstruction removeFromBlock.
	removedInstruction := OrderedCollection new.
	removedBlock instructionsDo: [:ins | removedInstruction add: ins].
	
	removedBlock instructionsDo: [ :instruction |
		removedBlock remove: instruction.
		block addLast: instruction
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
		oldSuccessors do: #predecessorsCouldBeRemoved.
		
		function removeBasicBlock: block.
		pendingWork addAll: oldSuccessors.
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
