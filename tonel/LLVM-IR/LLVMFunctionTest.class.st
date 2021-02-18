"
A LLVMFunctionTest is a test class for testing the behavior of LLVMFunction
"
Class {
	#name : #LLVMFunctionTest,
	#superclass : #TestCase,
	#instVars : [
		'context',
		'module'
	],
	#category : #'LLVM-IR-Tests'
}

{ #category : #initialization }
LLVMFunctionTest >> setUp [
	context := LLVMContext new.
	module := LLVMModule name: #testModule context: context
]

{ #category : #initialization }
LLVMFunctionTest >> testSquare [
	| functionType function x bb builder firstInstruction secondInstruction |
	functionType := LLVMFunctionType get: context int32Ty params: { context int32Ty } isVarArg: false.
	function := LLVMFunction createWithType: functionType linkage: LLVMGlobalValue externalLinkage name: #testFunction module: module.
	
	x := function arguments first.
	x name: #x.

	bb := LLVMBasicBlock for: context name: #entry parent: function.
	builder := LLVMIRBuilder forBasicBlock: bb.

	firstInstruction := builder mul: x with: x.
	secondInstruction := builder return: firstInstruction.
	
	self assert: function basicBlocks size equals: 1.
	self assert: firstInstruction parent equals: bb.
	self assert: secondInstruction parent equals: bb.
	self assert: secondInstruction value equals: firstInstruction.

]

{ #category : #initialization }
LLVMFunctionTest >> testVoidFunction [
	| functionType function bb builder firstInstruction |
	functionType := LLVMFunctionType get: context voidTy params: #() isVarArg: false.
	function := LLVMFunction createWithType: functionType linkage: LLVMGlobalValue externalLinkage name: #testFunction module: module.
	
	bb := LLVMBasicBlock for: context name: #entry parent: function.
	builder := LLVMIRBuilder forBasicBlock: bb.

	firstInstruction := builder returnVoid.
	
	self assert: function basicBlocks size equals: 1.
	self assert: firstInstruction parent equals: bb.
]

{ #category : #initialization }
LLVMFunctionTest >> testVoidFunctionDeclaration [
	| functionType function |
	functionType := LLVMFunctionType get: context voidTy params: #() isVarArg: false.
	function := LLVMFunction createWithType: functionType linkage: LLVMGlobalValue externalLinkage name: #testFunction module: module.
	
]
