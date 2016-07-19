Class {
	#name : #SLVMOptBasicOptimizations,
	#superclass : #SLVMFunctionOptimizationPass,
	#instVars : [
		'pendingWork'
	],
	#category : #'Slovim-Core-Optimizations'
}

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
]
