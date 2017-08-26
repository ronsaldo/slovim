"
A DAIRBuilderTest is a test class for testing the behavior of DAIRBuilder
"
Class {
	#name : #SLVMBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'functionType',
		'function',
		'builder'
	],
	#category : #'Slovim-Tests'
}

{ #category : #running }
SLVMBuilderTest >> setUp [
	functionType := SLVMFunctionType arguments: {SLVMType intType} returnType: SLVMType voidType.
	function := SLVMFunction name: #testFunction functionType: functionType.
	builder := SLVMBuilder on: function.
]

{ #category : #tests }
SLVMBuilderTest >> testConstBool [
	| constant |
	constant := builder constBool: true.
	self assert: constant isConstant.
	self assert: constant type = SLVMType boolType.
]

{ #category : #tests }
SLVMBuilderTest >> testConstDouble [
	| constant |
	constant := builder constDouble: 1.0.
	self assert: constant isConstant.
	self assert: constant type isFloatType.
]

{ #category : #tests }
SLVMBuilderTest >> testConstFloat [
	| constant |
	constant := builder constFloat: 1.0.
	self assert: constant isConstant.
	self assert: constant type = SLVMType floatType.
]

{ #category : #tests }
SLVMBuilderTest >> testConstInt [
	| constant |
	constant := builder constInt: 1.
	self assert: constant isConstant.
	self assert: constant type = SLVMType intType.
]

{ #category : #tests }
SLVMBuilderTest >> testConstLong [
	| constant |
	constant := builder constLong: 1.
	self assert: constant isConstant.
	self assert: constant type = SLVMType longType.
]

{ #category : #tests }
SLVMBuilderTest >> testConstUInt [
	| constant |
	constant := builder constUInt: 1.
	self assert: constant isConstant.
	self assert: constant type = SLVMType uintType.
]

{ #category : #tests }
SLVMBuilderTest >> testConstULong [
	| constant |
	constant := builder constULong: 1.
	self assert: constant isConstant.
	self assert: constant type = SLVMType ulongType.
]

{ #category : #tests }
SLVMBuilderTest >> testNew [
	self assert: builder function equals: function.
]

{ #category : #'as yet unclassified' }
SLVMBuilderTest >> testNewBasicBlock [
	| block |
	block := builder newBasicBlock.
	self assert: function basicBlocks first equals: block
]

{ #category : #'as yet unclassified' }
SLVMBuilderTest >> testReturn [
	| top instruction |
	top := builder newBasicBlock: #top.
	builder withBasicBlock: top do: [
		instruction := builder return: (builder constInt: 1)
	].

	self assert: instruction block function equals: function.
	self assert: function basicBlocks first firstInstruction equals: instruction.
]

{ #category : #'as yet unclassified' }
SLVMBuilderTest >> testReturnVoid [
	| top instruction |
	top := builder newBasicBlock: #top.
	builder withBasicBlock: top do: [
		instruction := builder returnVoid
	].

	self assert: instruction block function equals: function.
	self assert: function basicBlocks first firstInstruction equals: instruction.
]
