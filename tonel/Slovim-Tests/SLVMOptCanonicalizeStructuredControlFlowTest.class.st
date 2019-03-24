Class {
	#name : #SLVMOptCanonicalizeStructuredControlFlowTest,
	#superclass : #SLVMFunctionOptimizationTest,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMOptCanonicalizeStructuredControlFlowTest >> testIfNoMergeReturn [
	| ifBlock ifMerge |
	self functionArguments: { target bool } returnType: target int.

	builder sequenceWith: [
		builder if: function arguments first trueValueWith: [
			builder return: (builder constInt: 1)
		] falseValueWith: [
			builder return: (builder constInt: 2)
		].
	].

	ifBlock := function basicBlocks first.
	ifMerge := ifBlock mergeBlock.
	
	SLVMOptCanonicalizeStructuredControlFlow passOnFunction: function.
	
	self assert: ifBlock unreachableSuccessors isEmpty.
	
	self assert: ifMerge size equals: 2.
	self assert: ifMerge firstInstruction isPhi.
	self assert: ifMerge lastInstruction isReturn.
]

{ #category : #tests }
SLVMOptCanonicalizeStructuredControlFlowTest >> testIfReturn [
	| ifBlock ifMerge result |
	self functionArguments: { target bool } returnType: target int.

	builder sequenceWith: [
		result := builder if: function arguments first trueValueWith: [
			builder constInt: 1
		] falseValueWith: [
			builder constInt: 2
		].
	
		builder return: result.
	].

	ifBlock := function basicBlocks first.
	ifMerge := ifBlock mergeBlock.
	
	SLVMOptCanonicalizeStructuredControlFlow passOnFunction: function.
	
	self assert: ifBlock unreachableSuccessors isEmpty.
	
	self assert: ifMerge size equals: 2.
	self assert: ifMerge firstInstruction isPhi.
	self assert: ifMerge lastInstruction isReturn.
]
