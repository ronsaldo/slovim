Class {
	#name : #SLVMLLVMEquivalentBuiltInFunctionGenerator,
	#superclass : #SLVMLLVMOverloadedBuiltInFunctionGenerator,
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #'code generation' }
SLVMLLVMEquivalentBuiltInFunctionGenerator >> getOverloadedIntrinsicWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction [
	^ functionCodeGenerator llvmModule getIntrinsic: llvmBuiltIn orCreateWithType: [ 
		functionCodeGenerator translateType: builtInFunction functionType
	].

]
