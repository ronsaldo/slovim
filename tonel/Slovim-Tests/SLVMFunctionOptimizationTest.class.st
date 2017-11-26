Class {
	#name : #SLVMFunctionOptimizationTest,
	#superclass : #TestCase,
	#instVars : [
		'target',
		'module',
		'functionType',
		'function',
		'builder'
	],
	#category : #'Slovim-Tests'
}

{ #category : #initialization }
SLVMFunctionOptimizationTest >> functionArguments: argumentTypes returnType: returnType [
	functionType := SLVMFunctionType arguments: argumentTypes returnType: returnType.
	function := SLVMFunction module: module name: #testFunction functionType: functionType.
	builder := SLVMBuilder on: function.
]

{ #category : #initialization }
SLVMFunctionOptimizationTest >> setUp [
	target := SLVM32BitsPointerCompilationTarget new.
	module := SLVMModule new compilationTarget: target.
]
