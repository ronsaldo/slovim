"
This is a special pass for making sure that a function has a canonical structured control flow. Functions without a canonical control flow structure cannot be inlined without preserving structured control flow, which is required for GPU shaders.
"
Class {
	#name : #SLVMOptCanonicalizeStructuredControlFlow,
	#superclass : #SLVMFunctionOptimizationPass,
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #applying }
SLVMOptCanonicalizeStructuredControlFlow >> passOnFunction: aFunction [
	"Avoid duplicated work"
	| returnInstructions |
	aFunction canHaveCanonicalStructuredControlFlow ifFalse: [ ^ false ].
	aFunction hasCanonicalStructuredControlFlow ifTrue: [ ^ true ].
	
	"Find the return instructions."
	returnInstructions := OrderedCollection new.
	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :instruction |
			(instruction isReturn or: [ instruction isReturnVoid ]) ifTrue: [ 
				returnInstructions add: instruction
			].
		]
	].

	returnInstructions size = 0 ifTrue: [
		self flag: 'What should I do with the never return case?'.
		self halt.
	].

	returnInstructions size = 1 ifTrue: [ 
		^ aFunction
			canHaveCanonicalStructuredControlFlow: true;
			hasCanonicalStructuredControlFlow: true.
	].

	aFunction
		canHaveCanonicalStructuredControlFlow: false;
		hasCanonicalStructuredControlFlow: false.
]
