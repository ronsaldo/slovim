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
	| removedBlock |
	removedBlock := block lastInstruction destination.
	(removedBlock == block or: [ removedBlock predecessors size ~= 1 ]) ifTrue: [  ^ self ].

	block lastInstruction removeFromBlock.
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
	removedBlock removeFromFunction.
	pendingWork add: block
]

{ #category : #'as yet unclassified' }
SLVMOptBasicOptimizations >> passOnFunction: aFunction [
	| work |
	pendingWork ifNil: [ pendingWork := Set new ].
	pendingWork addAll: aFunction basicBlocks.
	[ pendingWork isNotEmpty ] whileTrue: [ 
		work := pendingWork anyOne.
		pendingWork remove: work.
		
		self processBlock: work
	]
]

{ #category : #private }
SLVMOptBasicOptimizations >> processBlock: block [
	| oldSuccessors |
	block function ifNil: [ ^ self ].
	
	(block index ~= 1 and: [ block predecessors isEmpty ]) ifTrue: [ 
		block isEmpty ifTrue: [
			block function removeBasicBlock: block.
			^ self
		].
	
		"Remove the unreachable block"
		oldSuccessors := block successors copy.
		block lastInstruction removeFromBlock.
		block successors: #().
		oldSuccessors do: #predecessorsCouldBeRemoved.
		
		block function removeBasicBlock: block.
		pendingWork addAll: oldSuccessors.
		^ self
	].

	block isEmpty ifTrue: [ ^ self ].
	
	block instructionsDo: [ :instruction |
		self processInstruction: instruction
	].

	(block lastInstruction isJump) ifTrue: [
		self mergeWithNextBlockOf: block
	] ifFalse: [
		(block lastInstruction isBranch) ifTrue: [ 
			self foldBranchAtBlock: block
		]
	]
]

{ #category : #'as yet unclassified' }
SLVMOptBasicOptimizations >> processInstruction: instruction [
	self removeDeadPureInstructions: instruction.
	instruction block ifNil: [ ^ self ].
	
	self foldConstant: instruction.
	instruction block ifNil: [ ^ self ].

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
