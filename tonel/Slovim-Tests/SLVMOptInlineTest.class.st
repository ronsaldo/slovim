Class {
	#name : #SLVMOptInlineTest,
	#superclass : #SLVMFunctionOptimizationTest,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMOptInlineTest >> testIfInline [
	| inlined return ifBlock |
	inlined := self functionArguments: { target bool } returnType: target int.
	function inlineMode: true.
	
	builder sequenceWith: [
		|result|
		result := builder if: function arguments first trueValueWith: [
			builder constInt: 1
		] falseValueWith: [
			builder constInt: 2
		].
		
		builder return: result
	].
	
	self functionArguments: #() returnType: target int.
	builder sequenceWith: [
		return := builder return: (builder call: inlined arguments: {builder constBool: false}).
	].

	SLVMOptInline withStructuredControlFlow passOnFunction: function.
	self assert: return value isPhi.
	
	ifBlock := function basicBlocks first successors first.
	self assert: ifBlock continueBlock isNil.
	self assert: ifBlock mergeBlock isNotNil.
	
	self assert: ifBlock mergeBlock successors first equals: return block.

]

{ #category : #tests }
SLVMOptInlineTest >> testIfInlineThenOptimize [
	| inlined return |
	inlined := self functionArguments: { target bool } returnType: target int.
	function inlineMode: true.
	
	builder sequenceWith: [
		|result|
		result := builder if: function arguments first trueValueWith: [
			builder constInt: 1
		] falseValueWith: [
			builder constInt: 2
		].
		
		builder return: result
	].
	
	self functionArguments: #() returnType: target int.
	builder sequenceWith: [
		return := builder return: (builder call: inlined arguments: {builder constBool: false}).
	].

	SLVMOptInline withStructuredControlFlow passOnFunction: function.
	SLVMOptBasicOptimizations passOnFunction: function.

	self assert: function basicBlocks size equals: 1.
	self assert: return value isConstantValue.
	self assert: return value value equals: 2.
	
]

{ #category : #tests }
SLVMOptInlineTest >> testIfInlineThenOptimize2 [
	| inlined return |
	inlined := self functionArguments: { target bool } returnType: target int.
	function inlineMode: true.
	
	builder sequenceWith: [
		|result|
		result := builder if: function arguments first trueValueWith: [
			builder constInt: 1
		] falseValueWith: [
			builder constInt: 2
		].
		
		builder return: result
	].
	
	self functionArguments: #() returnType: target int.
	builder sequenceWith: [
		return := builder return: (builder call: inlined arguments: {builder constBool: true}).
	].

	SLVMOptInline withStructuredControlFlow passOnFunction: function.
	SLVMOptBasicOptimizations passOnFunction: function.

	self assert: function basicBlocks size equals: 1.
	self assert: return value isConstantValue.
	self assert: return value value equals: 1.
	
]

{ #category : #tests }
SLVMOptInlineTest >> testIfInlineWithoutMerge [
	| inlined return ifBlock |
	inlined := self functionArguments: { target bool } returnType: target int.
	function inlineMode: true.
	
	builder sequenceWith: [
		|result|
		result := builder if: function arguments first trueValueWith: [
			builder return: (builder constInt: 1)
		] falseValueWith: [
			builder return: (builder constInt: 2)
		].
	].
	
	self functionArguments: #() returnType: target int.
	builder sequenceWith: [
		return := builder return: (builder call: inlined arguments: {builder constBool: false}).
	].

	SLVMOptInline withStructuredControlFlow passOnFunction: function.
	self assert: return value isPhi.
	
	ifBlock := function basicBlocks first successors first.
	self assert: ifBlock continueBlock isNil.
	self assert: ifBlock mergeBlock isNotNil.
	
	self assert: ifBlock mergeBlock successors first equals: return block.

]

{ #category : #tests }
SLVMOptInlineTest >> testInlineNop [
	| inlined return |
	inlined := self functionArguments: { target int } returnType: target int.
	function inlineMode: true.
	
	builder sequenceWith: [ builder return: function arguments first ].
	
	self functionArguments: #() returnType: target int.
	builder sequenceWith: [
		return := builder return: (builder call: inlined arguments: {builder constInt: 42}).
	].

	SLVMOptInline withStructuredControlFlow passOnFunction: function.
	self assert: return value isConstantValue.
	self assert: return value value equals: 42
]
