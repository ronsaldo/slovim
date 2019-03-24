"
A DAIRBuilderTest is a test class for testing the behavior of DAIRBuilder
"
Class {
	#name : #SLVMBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'functionType',
		'function',
		'builder',
		'target',
		'module',
		'intArgument'
	],
	#category : #'Slovim-Tests'
}

{ #category : #running }
SLVMBuilderTest >> createFunctionWithArgumentTypes: argumentTypes returnType: returnType [
	intArgument := nil.

	functionType := SLVMFunctionType arguments: argumentTypes returnType: returnType.
	function := SLVMFunction module: module name: #testFunction functionType: functionType.
	builder := SLVMBuilder on: function.

]

{ #category : #running }
SLVMBuilderTest >> createIntFunction [
	self createFunctionWithArgumentTypes: {target int} returnType: target int.
	intArgument := function arguments first.

]

{ #category : #running }
SLVMBuilderTest >> createNullaryProcedure [
	self createFunctionWithArgumentTypes: #() returnType: target void.

]

{ #category : #running }
SLVMBuilderTest >> setUp [
	target := SLVM32BitsPointerCompilationTarget new.
	module := SLVMModule new compilationTarget: target.
	self createIntFunction

]

{ #category : #arithmetic }
SLVMBuilderTest >> testAdd [
	| left right top result |
	left := intArgument.
	right := builder constInt: 2.
	
	top := builder newBasicBlock: #top.
	builder withBasicBlock: top do: [
		result := builder add: left with: right.
	].

	self assert: result isBinaryOperation.
	self assert: result parameters equals: {left . right}.
	self assert: result left equals: left.
	self assert: result right equals: right.
	self assert: result type isIntegerType.
]

{ #category : #constants }
SLVMBuilderTest >> testConstBool [
	| constant |
	constant := builder constBool: true.
	self assert: constant isConstant.
	self assert: constant type = SLVMType boolType.
]

{ #category : #constants }
SLVMBuilderTest >> testConstDouble [
	| constant |
	constant := builder constDouble: 1.0.
	self assert: constant isConstant.
	self assert: constant type isFloatType.
]

{ #category : #constants }
SLVMBuilderTest >> testConstFloat [
	| constant |
	constant := builder constFloat: 1.0.
	self assert: constant isConstant.
	self assert: constant type = SLVMType floatType.
]

{ #category : #constants }
SLVMBuilderTest >> testConstInt [
	| constant |
	constant := builder constInt: 1.
	self assert: constant isConstant.
	self assert: constant type = SLVMType intType.
]

{ #category : #constants }
SLVMBuilderTest >> testConstLong [
	| constant |
	constant := builder constLong: 1.
	self assert: constant isConstant.
	self assert: constant type = SLVMType longType.
]

{ #category : #constants }
SLVMBuilderTest >> testConstUInt [
	| constant |
	constant := builder constUInt: 1.
	self assert: constant isConstant.
	self assert: constant type = SLVMType uintType.
]

{ #category : #constants }
SLVMBuilderTest >> testConstULong [
	| constant |
	constant := builder constULong: 1.
	self assert: constant isConstant.
	self assert: constant type = SLVMType ulongType.
]

{ #category : #'high level structures' }
SLVMBuilderTest >> testDoWhileSequence [
	| sequence |
	sequence := builder sequenceWith: [ :b |
		builder doWith: [ 
			nil
		] whileWith: [ builder constBool: false ].
	
		b return: intArgument
	].

	self assert: sequence block equals: function basicBlocks first.
	self assert: sequence exitBlock equals: function basicBlocks last.
	self assert: sequence result equals: nil.
]

{ #category : #'high level structures' }
SLVMBuilderTest >> testIfExpression [
	| const3 result entrySequence branch |
	entrySequence := builder sequenceWith: [
		const3 := builder constInt: 3.
		result := builder if: (builder ilt: intArgument with: const3) trueValueWith: [ 
			intArgument
		] falseValueWith: [
			const3
		].
	
		builder return: result
	].

	branch := function basicBlocks first lastInstruction.
	self assert: branch isBranch.
	self assert: branch block mergeBlock isNotNil.
	self assert: branch block continueBlock isNil.
	self assert: function basicBlocks size equals: 4.
	self assert: entrySequence block equals: function basicBlocks first.
	self assert: entrySequence exitBlock equals: function basicBlocks last.


]

{ #category : #'high level structures' }
SLVMBuilderTest >> testIfExpressionNoMerge [
	| const3 entrySequence branch |
	entrySequence := builder sequenceWith: [
		const3 := builder constInt: 3.
		builder if: (builder ilt: intArgument with: const3) trueValueWith: [ 
			builder return: intArgument
		] falseValueWith: [
			builder return: const3
		].		
	].

	branch := function basicBlocks first lastInstruction.
	self assert: branch isBranch.
	self assert: branch block mergeBlock isNotNil.
	self assert: branch block continueBlock isNil.
	self assert: function basicBlocks size equals: 4.
	self assert: entrySequence block equals: function basicBlocks first.
	self assert: entrySequence exitBlock equals: function basicBlocks last.
	self assert: function basicBlocks last lastInstruction isUnreachable.


]

{ #category : #branches }
SLVMBuilderTest >> testIfSelection [
	| entry constant result condition trueBlock falseBlock branch mergeBlock |
	entry := builder newBasicBlock: #entry.
	trueBlock := builder newBasicBlock: #trueBlock.
	falseBlock := builder newBasicBlock: #falseBlock.
	mergeBlock := builder newBasicBlock: #mergeBlock.
	constant := builder constInt: 3.
	
	builder withBasicBlock: entry do: [
		result := builder alloca: target int.
		condition := builder ilt: intArgument with: constant.
		branch := builder branch: condition ifTrue: trueBlock ifFalse: falseBlock.
		branch block mergeBlock: mergeBlock.
	].

	builder withBasicBlock: trueBlock do: [
		builder store: intArgument in: result.
		builder jump: mergeBlock
	].

	builder withBasicBlock: falseBlock do: [
		builder store: constant in: result.
		builder jump: mergeBlock
	].

	builder withBasicBlock: mergeBlock do: [
		builder return: (builder load: result)
	].

	self assert: branch isBranch.
	self assert: branch isTerminator.
	self assert: branch trueBlock equals: trueBlock.
	self assert: branch falseBlock equals: falseBlock.
	self assert: branch block mergeBlock equals: mergeBlock.
	self assert: branch block continueBlock equals: nil.

	self assert: entry successors equals: {trueBlock . falseBlock}.
	self assert: mergeBlock predecessors equals: {trueBlock . falseBlock}.
]

{ #category : #branches }
SLVMBuilderTest >> testIfSelectionNoMerge [
	| entry constant condition trueBlock falseBlock branch mergeBlock |
	entry := builder newBasicBlock: #entry.
	trueBlock := builder newBasicBlock: #trueBlock.
	falseBlock := builder newBasicBlock: #falseBlock.
	mergeBlock := builder newBasicBlock: #mergeBlock.
	constant := builder constInt: 3.
	
	builder withBasicBlock: entry do: [
		condition := builder ilt: intArgument with: constant.
		branch := builder branch: condition ifTrue: trueBlock ifFalse: falseBlock.
		branch block mergeBlock: mergeBlock.
	].

	builder withBasicBlock: trueBlock do: [
		builder return: intArgument.
	].

	builder withBasicBlock: falseBlock do: [
		builder return: constant.
	].

	builder withBasicBlock: mergeBlock do: [
		builder unreachable
	].

	branch block addUnreachableStructuredSuccessors.
	self assert: branch isBranch.
	self assert: branch isTerminator.
	self assert: branch trueBlock equals: trueBlock.
	self assert: branch falseBlock equals: falseBlock.
	self assert: branch block mergeBlock equals: mergeBlock.
	self assert: branch block continueBlock equals: nil.

	self assert: entry successors equals: {trueBlock . falseBlock . mergeBlock}.
	self assert: mergeBlock predecessors equals: {entry}.
]

{ #category : #branches }
SLVMBuilderTest >> testJump [
	| entry body jump  |
	entry := builder newBasicBlock: #entry.
	body := builder newBasicBlock: #body.
	builder withBasicBlock: entry do: [
		jump := builder jump: body.
	].

	builder withBasicBlock: body do: [
		builder return: intArgument
	].

	self assert: jump isJump.
	self assert: jump isTerminator.
	self assert: jump destination equals: body.
	self assert: entry successors equals: {body}.
	self assert: body predecessors equals: {entry}.
]

{ #category : #tests }
SLVMBuilderTest >> testNew [
	self assert: builder function equals: function.
]

{ #category : #tests }
SLVMBuilderTest >> testNewBasicBlock [
	| block |
	block := builder newBasicBlock.
	self assert: function basicBlocks first equals: block
]

{ #category : #'high level structures' }
SLVMBuilderTest >> testRangeLoopSequence [
	| sequence sum |
	sequence := builder sequenceWith: [ :b |
		sum := builder alloca: target int.
		builder from: (builder constInt: 0) to: (builder constInt: 10) by: (builder constInt: 1) doSequenceWith: [ :i |
			builder add: (builder load: sum) with: i
		].
	
		b return: (builder load: sum)
	].

	self assert: sequence block equals: function basicBlocks first.
	self assert: sequence exitBlock equals: function basicBlocks last.
	self assert: sequence result equals: nil.
]

{ #category : #tests }
SLVMBuilderTest >> testReturn [
	| top instruction |
	top := builder newBasicBlock: #top.
	builder withBasicBlock: top do: [
		instruction := builder return: (builder constInt: 1)
	].

	self assert: instruction block function equals: function.
	self assert: function basicBlocks first firstInstruction equals: instruction.
]

{ #category : #tests }
SLVMBuilderTest >> testReturnVoid [
	| top instruction |
	self createNullaryProcedure.
	
	top := builder newBasicBlock: #top.
	builder withBasicBlock: top do: [
		instruction := builder returnVoid
	].

	self assert: instruction block function equals: function.
	self assert: function basicBlocks first firstInstruction equals: instruction.
]

{ #category : #'high level structures' }
SLVMBuilderTest >> testSequence [
	| sequence |
	sequence := builder sequenceWith: [ :b |
		b return: intArgument
	].

	self assert: sequence block equals: function basicBlocks first.
	self assert: sequence exitBlock equals: function basicBlocks last.
	self assert: sequence result equals: nil.
]

{ #category : #'high level structures' }
SLVMBuilderTest >> testWhileSequence [
	| sequence |
	sequence := builder sequenceWith: [ :b |
		builder whileWith: [ builder constBool: false ] doWith: [ 
			nil
		].
	
		b return: intArgument
	].

	self assert: sequence block equals: function basicBlocks first.
	self assert: sequence exitBlock equals: function basicBlocks last.
	self assert: sequence result equals: nil.
]
