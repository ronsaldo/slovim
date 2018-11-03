Class {
	#name : #SLVMLLVMOverloadedBuiltInFunctionGenerator,
	#superclass : #SLVMLLVMBuiltInFunctionGenerator,
	#instVars : [
		'llvmBuiltIn'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #'code generation' }
SLVMLLVMOverloadedBuiltInFunctionGenerator >> generateWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction [
	| overloadedIntrinsic |
	overloadedIntrinsic := self getOverloadedIntrinsicWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction.
	^ functionCodeGenerator
		call: overloadedIntrinsic
		arguments: (instruction arguments collect: [:arg | functionCodeGenerator translateValue: arg])
		returnType: (functionCodeGenerator translateType: instruction type)
		name: (functionCodeGenerator convertName: instruction name)
]

{ #category : #'code generation' }
SLVMLLVMOverloadedBuiltInFunctionGenerator >> getOverloadedIntrinsicWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMLLVMOverloadedBuiltInFunctionGenerator >> llvmBuiltIn [
	^ llvmBuiltIn
]

{ #category : #accessing }
SLVMLLVMOverloadedBuiltInFunctionGenerator >> llvmBuiltIn: anObject [
	llvmBuiltIn := anObject
]
