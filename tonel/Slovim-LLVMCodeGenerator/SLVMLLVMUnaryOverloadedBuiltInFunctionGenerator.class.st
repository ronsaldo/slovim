Class {
	#name : #SLVMLLVMUnaryOverloadedBuiltInFunctionGenerator,
	#superclass : #SLVMLLVMOverloadedBuiltInFunctionGenerator,
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #'code generation' }
SLVMLLVMUnaryOverloadedBuiltInFunctionGenerator >> getOverloadedIntrinsicWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction [
	| llvmArgumentType overloadedBuiltInName |
	llvmArgumentType := functionCodeGenerator translateType: builtInFunction functionType arguments first.
	overloadedBuiltInName := (llvmBuiltIn , '.', llvmArgumentType overloadedIntrinsicName) asSymbol.
	^ functionCodeGenerator llvmModule getIntrinsic: overloadedBuiltInName orCreateWithType: [ 
		functionCodeGenerator translateType: builtInFunction functionType
	].

]
