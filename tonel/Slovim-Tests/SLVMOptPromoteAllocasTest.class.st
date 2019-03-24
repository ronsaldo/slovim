"
A SLVMOptPromoteAllocasTest is a test class for testing the behavior of SLVMOptPromoteAllocas
"
Class {
	#name : #SLVMOptPromoteAllocasTest,
	#superclass : #SLVMFunctionOptimizationTest,
	#category : #'Slovim-Tests'
}

{ #category : #initialization }
SLVMOptPromoteAllocasTest >> setUp [
	super setUp.
	
	matrixStruct := SLVMStructureType name: #testMatrix
		types: {target float . target float . target float . target float}
		kind: SLVMStructureType genericKind names: #(m11 m12 m21 m22).


]

{ #category : #tests }
SLVMOptPromoteAllocasTest >> testBranch [
	| entryBlock variable trueBlock falseBlock mergeBlock |
	self functionArguments: { target int . target int} returnType: target int.
	
	entryBlock := builder newBasicBlockHere: #entry.
	trueBlock := builder newBasicBlock: #trueBlock.
	falseBlock := builder newBasicBlock: #falseBlock.
	mergeBlock := builder newBasicBlock: #mergeBlock.

	variable := builder alloca: target int.
	builder
		branch: (builder ilt: function arguments first with: function arguments second) ifTrue: trueBlock ifFalse: falseBlock;
		
		currentBlock: trueBlock;
		store: (function arguments first) in: variable;
		jump: mergeBlock;

		currentBlock: falseBlock;
		store: (function arguments second) in: variable;
		jump: mergeBlock;
		
		currentBlock: mergeBlock;
		return: (builder load: variable).
		
	SLVMOptPromoteAllocas passOnFunction: function.
	
	self assert: entryBlock size equals: 2.

	self assert: trueBlock size equals: 1.
	self assert: trueBlock firstInstruction isJump.

	self assert: falseBlock size equals: 1.
	self assert: falseBlock firstInstruction isJump.

	self assert: mergeBlock size equals: 2.
	self assert: mergeBlock firstInstruction isPhi.
	self assert: mergeBlock firstInstruction nextInstruction isReturn.
]

{ #category : #tests }
SLVMOptPromoteAllocasTest >> testHalfBranch [
	| entryBlock variable falseBlock mergeBlock |
	self functionArguments: { target int . target int } returnType: target int.
	
	entryBlock := builder newBasicBlockHere: #entry.
	falseBlock := builder newBasicBlock: #falseBlock.
	mergeBlock := builder newBasicBlock: #mergeBlock.

	variable := builder alloca: target int.
	builder
		store: (function arguments first) in: variable;
		branch: (builder ilt: function arguments first with: function arguments second) ifTrue: mergeBlock ifFalse: falseBlock;

		currentBlock: falseBlock;
		store: (function arguments second) in: variable;
		jump: mergeBlock;
		
		currentBlock: mergeBlock;
		return: (builder load: variable).
		
	SLVMOptPromoteAllocas passOnFunction: function.
	
	self assert: entryBlock size equals: 2.

	self assert: falseBlock size equals: 1.
	self assert: falseBlock firstInstruction isJump.

	self assert: mergeBlock size equals: 2.
	self assert: mergeBlock firstInstruction isPhi.
	self assert: mergeBlock firstInstruction nextInstruction isReturn.
]

{ #category : #tests }
SLVMOptPromoteAllocasTest >> testRangeLoopSum [
	| sum sequence return |
	self functionArguments: #() returnType: target int.
	
	sequence := builder sequenceWith: [ :b |
		sum := builder alloca: target int.
		builder store: (builder constInt: 0) in: sum.
		
		builder from: (builder constInt: 0) to: (builder constInt: 10) by: (builder constInt: 1) doSequenceWith: [ :i |
			builder store: (builder add: (builder load: sum) with: i)
				in: sum
		].
	
		return := b return: (builder load: sum)
	].

	SLVMOptPromoteAllocas passOnFunction: function.

	self assert: sequence block equals: function basicBlocks first.
	self assert: sequence exitBlock equals: function basicBlocks last.
	self assert: sequence result equals: nil.
	
	self assert: return value isPhi
]

{ #category : #tests }
SLVMOptPromoteAllocasTest >> testRangeLoopUndefinedSum [
	| sum sequence return |
	self functionArguments: #() returnType: target int.
	
	sequence := builder sequenceWith: [ :b |
		sum := builder alloca: target int.
	
		builder from: (builder constInt: 0) to: (builder constInt: 10) by: (builder constInt: 1) doSequenceWith: [ :i |
			builder store: (builder add: (builder load: sum) with: i)
				in: sum
		].
	
		return := b return: (builder load: sum)
	].

	SLVMOptPromoteAllocas passOnFunction: function.

	self assert: sequence block equals: function basicBlocks first.
	self assert: sequence exitBlock equals: function basicBlocks last.
	self assert: sequence result equals: nil.
	
	self assert: return value isPhi.
]

{ #category : #tests }
SLVMOptPromoteAllocasTest >> testSingleBlock [
	| entryBlock variable |
	self functionArguments: #() returnType: target int.
	
	entryBlock := builder newBasicBlockHere: #entry.
	variable := builder alloca: target int.
	builder
		store: (builder constInt: 3) in: variable;
		return: (builder load: variable).
		
	SLVMOptPromoteAllocas passOnFunction: function.

	self assert: entryBlock size = 1.
	self assert: entryBlock firstInstruction isReturn.
	self assert: entryBlock firstInstruction value isConstantValue.
	self assert: entryBlock firstInstruction value value equals: 3.
]

{ #category : #tests }
SLVMOptPromoteAllocasTest >> testStructureExtractValue [
	| entryBlock variable |
	self functionArguments: { matrixStruct } returnType: target float.
	
	entryBlock := builder newBasicBlockHere: #entry.
	variable := builder alloca: matrixStruct.
	builder
		store: function arguments first in: variable;
		return: (builder load: (builder getReference: variable element: (builder constInt: 0))).
		
	SLVMOptPromoteAllocas passOnFunction: function.
	
	self assert: entryBlock size = 2.
	self assert: entryBlock firstInstruction isExtractValue.
	self assert: entryBlock firstInstruction nextInstruction isReturn.
	self assert: entryBlock firstInstruction nextInstruction value == entryBlock firstInstruction.
]
