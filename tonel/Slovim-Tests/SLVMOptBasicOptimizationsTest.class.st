Class {
	#name : #SLVMOptBasicOptimizationsTest,
	#superclass : #SLVMFunctionOptimizationTest,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMOptBasicOptimizationsTest >> testFoldFalseBranch [
	| entryBlock result |
	self functionArguments: #() returnType: target int.
	
	builder sequenceWith: [ 
		result := builder if: (builder constBool: false) trueValueWith: [ 
			builder constInt: 1.
		] falseValueWith: [ 
			builder constInt: 2.
		].
	
		builder return: result.
	].

	self assert: function asFullSExpression equals: #(
		function testFunction cdecl i32 ()
			arguments ()
		blocks (
			((merge (block 4 #ifMerge)) 
				(nil branch void () ((const b8 false)) ((block 2 ifTrue) (block 3 ifFalse)))
			)
			(() 
				(nil jump void () () (block 4 ifMerge))
			)
			(()
				(nil jump void () () (block 4 ifMerge))
			)
			(()
				(nil phi i32 () ((const i32 1) #(const i32 2)) ((block 2 ifTrue) (block 3 ifFalse)))
				(nil return void () ((local nil nil))))
			)
	).
	
	SLVMOptBasicOptimizations passOnFunction: function.
	
	entryBlock := function basicBlocks first.
	self assert: function asFullSExpression equals: #(
		function testFunction cdecl i32 ()
		arguments ()
		blocks (
			(()
				(nil return void () ((const i32 2)))
			)
		)
	).

]

{ #category : #tests }
SLVMOptBasicOptimizationsTest >> testFoldTrueBranch [
	| entryBlock result |
	self functionArguments: #() returnType: target int.
	
	builder sequenceWith: [ 
		result := builder if: (builder constBool: true) trueValueWith: [ 
			builder constInt: 1.
		] falseValueWith: [ 
			builder constInt: 2.
		].
	
		builder return: result.
	].

	self assert: function asFullSExpression equals: #(
		function testFunction cdecl i32 ()
			arguments ()
		blocks (
			((merge (block 4 #ifMerge)) 
				(nil branch void () ((const b8 true)) ((block 2 ifTrue) (block 3 ifFalse)))
			)
			(() 
				(nil jump void () () (block 4 ifMerge))
			)
			(()
				(nil jump void () () (block 4 ifMerge))
			)
			(()
				(nil phi i32 () ((const i32 1) #(const i32 2)) ((block 2 ifTrue) (block 3 ifFalse)))
				(nil return void () ((local nil nil))))
			)
	).
	
	SLVMOptBasicOptimizations passOnFunction: function.
	
	entryBlock := function basicBlocks first.
	self assert: function asFullSExpression equals: #(
		function testFunction cdecl i32 ()
		arguments ()
		blocks (
			(()
				(nil return void () ((const i32 1)))
			)
		)
	).

]

{ #category : #tests }
SLVMOptBasicOptimizationsTest >> testMergeBlocks [
	| entryBlock returnBlock |
	self functionArguments: #() returnType: target int.
	
	entryBlock := builder newBasicBlockHere: #entry.
	returnBlock := builder newBasicBlock: #exitBlock.
	builder
		jump: returnBlock;
		currentBlock: returnBlock;
		return: (builder constInt: 2).

	SLVMOptBasicOptimizations passOnFunction: function.
	self assert: entryBlock size equals: 1.
	self assert: entryBlock firstInstruction isReturn.
	self assert: entryBlock firstInstruction value isConstantValue.
	self assert: entryBlock firstInstruction value value equals: 2.
]

{ #category : #tests }
SLVMOptBasicOptimizationsTest >> testMergeBlocksPhi [
	| entryBlock returnBlock |
	self functionArguments: #() returnType: target int.
	
	entryBlock := builder newBasicBlockHere: #entry.
	returnBlock := builder newBasicBlock: #exitBlock.
	builder
		jump: returnBlock;
		currentBlock: returnBlock;
		return: ((builder phi: target int)
			addValue: (builder constInt: 2) from: entryBlock).

	SLVMOptBasicOptimizations passOnFunction: function.
	self assert: entryBlock size equals: 1.
	self assert: entryBlock firstInstruction isReturn.
	self assert: entryBlock firstInstruction value isConstantValue.
	self assert: entryBlock firstInstruction value value equals: 2.
]

{ #category : #tests }
SLVMOptBasicOptimizationsTest >> testMergeEntryBlockWithIf [
	| entryBlock body mergeBlock |
	self functionArguments: {target bool} returnType: target int.
	
	entryBlock := builder newBasicBlockHere: #entry.
	
	body := builder sequenceWith: [ 
		builder if: function arguments first trueValueWith: [
			builder return: (builder constInt: 1)
		] falseValueWith: [ 
			builder return: (builder constInt: 2)
		]
	].
	builder jump: body block.

	SLVMOptBasicOptimizations passOnFunction: function.

	mergeBlock := entryBlock mergeBlock.
	self assert: function basicBlocks size equals: 4.
	self assert: entryBlock size equals: 1.
	self assert: (entryBlock successors includes: mergeBlock).
	self assert: mergeBlock predecessors equals: {entryBlock}.
]

{ #category : #tests }
SLVMOptBasicOptimizationsTest >> testMergeLoopBlock [
	| entryBlock body mergeBlock lastValue loopHeader loopBody loopExit |
	self functionArguments: {target bool} returnType: target int.
	
	entryBlock := builder newBasicBlockHere: #entry.
	lastValue := builder alloca: target int.
	
	body := builder sequenceWith: [ 
		builder from: (builder constInt: 0) to: (builder constInt: 2) doSequenceWith: [ :i |
			builder store: i in: lastValue
		].
	
		builder return: (builder load: lastValue)
	].

	builder jump: body block.
	
	SLVMOptBasicOptimizations passOnFunction: function.

	mergeBlock := entryBlock mergeBlock.
	loopHeader := function basicBlocks second.
	loopBody := function basicBlocks third.
	loopExit := function basicBlocks last.
	
	self assert: function basicBlocks size <= 5.
	self assert: entryBlock size equals: 2.
	self assert: loopHeader mergeBlock equals: loopExit.
	self assert: loopHeader continueBlock function equals: function.

]
