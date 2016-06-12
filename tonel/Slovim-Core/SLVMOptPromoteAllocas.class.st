Class {
	#name : #SLVMOptPromoteAllocas,
	#superclass : #SLVMFunctionOptimizationPass,
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> canBePromoted: allocaInstruction [
	allocaInstruction instructionReferences do: [ :ref |
		(ref isLoad not and: [ ref isStore not ]) ifTrue: [ ^ false ]
	].

	^ true
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> passOnFunction: aFunction [
	| toBePromoted |
	toBePromoted := OrderedCollection new.
	aFunction basicBlocks first instructions do: [ :ins |
		(ins isAlloca and: [self canBePromoted: ins]) ifTrue: [ 
			toBePromoted add: ins
		]
	].

	toBePromoted do: [ :alloca | self promote: alloca ]
]

{ #category : #'as yet unclassified' }
SLVMOptPromoteAllocas >> promote: allocaInstruction [
	| hasLoad hasStore |
	hasLoad := false.
	hasStore := false.
	allocaInstruction instructionReferences do: [ :ref |
		ref isLoad ifTrue: [ hasLoad := true ].
		ref isStore ifTrue: [ hasStore := true ].
	].

	(hasLoad not) ifTrue: [
		"This variable is not used"
		allocaInstruction instructionReferences do: #removeFromBlock.
		allocaInstruction removeFromBlock.
		^ self
	].

	(hasStore not) ifTrue: [
		"This variable is never set. It always contains the default value."
		self halt.
		^ self
	].

]
