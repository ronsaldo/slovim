"
A DAIRFunctionTest is a test class for testing the behavior of DAIRFunction
"
Class {
	#name : #SLVMFunctionTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #'as yet unclassified' }
SLVMFunctionTest >> testGenerateSymbol [
	| functionType function gsym1 gsym2 |
	functionType := SLVMFunctionType arguments: {SLVMType intType} returnType: SLVMType voidType.
	function := SLVMFunction name: #testFunction functionType: functionType.
	gsym1 := function generateSymbol.
	gsym2 := function generateSymbol.
	self assert: gsym1 isSymbol.
	self assert: gsym2 isSymbol.
	self assert: gsym1 ~= gsym2.
]

{ #category : #'as yet unclassified' }
SLVMFunctionTest >> testNew [
	| functionType function |
	functionType := SLVMFunctionType arguments: {SLVMType intType} returnType: SLVMType voidType.
	function := SLVMFunction pointerSize: 4 name: #testFunction functionType: functionType.
	self assert: function functionType equals: functionType.
	self assert: function type equals: (SLVMPointerType size: 4 baseType: functionType storage: SLVMType genericStorage).
	self assert: function arguments size equals: 1.
]
