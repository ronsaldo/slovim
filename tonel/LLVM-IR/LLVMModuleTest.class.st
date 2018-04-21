"
A LLVMModuleTest is a test class for testing the behavior of LLVMModule
"
Class {
	#name : #LLVMModuleTest,
	#superclass : #TestCase,
	#instVars : [
		'context',
		'module'
	],
	#category : #'LLVM-IR-Tests'
}

{ #category : #initialization }
LLVMModuleTest >> setUp [
	context := LLVMContext new.
]

{ #category : #tests }
LLVMModuleTest >> testNew [
	module := LLVMModule name: #test context: context.
	self assert: module name equals: #test.
	self assert: module context equals: context.
]
