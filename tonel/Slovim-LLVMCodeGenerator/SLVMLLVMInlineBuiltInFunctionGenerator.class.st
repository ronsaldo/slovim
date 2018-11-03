Class {
	#name : #SLVMLLVMInlineBuiltInFunctionGenerator,
	#superclass : #SLVMLLVMBuiltInFunctionGenerator,
	#instVars : [
		'block'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #accessing }
SLVMLLVMInlineBuiltInFunctionGenerator >> block [
	^ block
]

{ #category : #accessing }
SLVMLLVMInlineBuiltInFunctionGenerator >> block: anObject [
	block := anObject
]

{ #category : #'code generation' }
SLVMLLVMInlineBuiltInFunctionGenerator >> generateWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction [
	^ block cull: functionCodeGenerator cull: builtInFunction cull: instruction
]
