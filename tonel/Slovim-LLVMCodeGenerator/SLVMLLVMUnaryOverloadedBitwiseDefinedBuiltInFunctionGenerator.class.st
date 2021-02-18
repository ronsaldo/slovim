Class {
	#name : #SLVMLLVMUnaryOverloadedBitwiseDefinedBuiltInFunctionGenerator,
	#superclass : #SLVMLLVMUnaryOverloadedBuiltInFunctionGenerator,
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #'code generation' }
SLVMLLVMUnaryOverloadedBitwiseDefinedBuiltInFunctionGenerator >> generateWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction [
	| overloadedIntrinsic |
	overloadedIntrinsic := self getOverloadedIntrinsicWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction.
	^ functionCodeGenerator
		call: overloadedIntrinsic
		arguments: (instruction arguments collect: [:arg | functionCodeGenerator translateValue: arg]) ,
			{ functionCodeGenerator translateValue: (SLVMConstant bool: true) }
		returnType: (functionCodeGenerator translateType: instruction type)
		name: (functionCodeGenerator convertName: instruction name)
]

{ #category : #'code generation' }
SLVMLLVMUnaryOverloadedBitwiseDefinedBuiltInFunctionGenerator >> getOverloadedIntrinsicWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction [
	| llvmArgumentType overloadedBuiltInName functionType |
	functionType := builtInFunction functionType withAppendedArguments: {SLVMType boolType}.
	llvmArgumentType := functionCodeGenerator translateType: builtInFunction functionType arguments first.
	overloadedBuiltInName := (llvmBuiltIn , '.', llvmArgumentType overloadedIntrinsicName) asSymbol.
	^ functionCodeGenerator llvmModule getIntrinsic: overloadedBuiltInName orCreateWithType: [ 
		functionCodeGenerator translateType: functionType
	].

]
