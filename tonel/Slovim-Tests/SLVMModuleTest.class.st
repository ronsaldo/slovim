Class {
	#name : #SLVMModuleTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMModuleTest >> testNew [
	| module |
	module := SLVMModule new.
	self assert: module globalValues isEmpty
]

{ #category : #tests }
SLVMModuleTest >> testSerialization [
	| module serialized loadedModule |
	module := SLVMModule new.
	self assert: module globalValues isEmpty.
	serialized := module asFullSExpression.
		
	loadedModule := SLVMModule new.
	loadedModule decodeFromFullSExpression: serialized.
	self assert: loadedModule globalValues isEmpty.
]

{ #category : #tests }
SLVMModuleTest >> testSerialization2 [
	| module serialized loadedModule target function |
	target := SLVMCompilationTarget x86_64.
	module := SLVMModule new.
	module compilationTarget: target.
	function := SLVMFunction module: module name: #main functionType: (SLVMFunctionType arguments: #() returnType: SLVMType intType).
	function makeExternal.
	
	self assert: module globalValues size equals: 1.
	serialized := module asFullSExpression.
		
	loadedModule := SLVMModule new.
	loadedModule compilationTarget: target.
	loadedModule decodeFromFullSExpression: serialized.
	self assert: loadedModule globalValues size equals: 1.
]

{ #category : #tests }
SLVMModuleTest >> testSerialization3 [
	| module serialized loadedModule target function |
	target := SLVMCompilationTarget x86_64.
	module := SLVMModule new.
	module compilationTarget: target.
	function := SLVMFunction module: module name: #main functionType: (SLVMFunctionType arguments: #() returnType: SLVMType intType).
	function makePublic.
	(SLVMBuilder on: function)
		newBasicBlockHere: #entry;
		return: (SLVMConstant int: 42).
	
	self assert: module globalValues size equals: 1.
	serialized := module asFullSExpression.
		
	loadedModule := SLVMModule new.
	loadedModule compilationTarget: target.
	loadedModule decodeFromFullSExpression: serialized.
	self assert: loadedModule globalValues size equals: 1.
]
