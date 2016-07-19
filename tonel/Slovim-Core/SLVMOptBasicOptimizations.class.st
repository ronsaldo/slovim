Class {
	#name : #SLVMOptBasicOptimizations,
	#superclass : #SLVMFunctionOptimizationPass,
	#instVars : [
		'pendingWork'
	],
	#category : #'Slovim-Core-Optimizations'
}

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

{ #category : #'as yet unclassified' }
SLVMOptBasicOptimizations >> processBlock: block [

	block instructionsDo: [ :instruction |
		self processInstruction: instruction
	].

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
