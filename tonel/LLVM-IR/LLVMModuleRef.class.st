Class {
	#name : #LLVMModuleRef,
	#superclass : #LLVMDisposableRef,
	#instVars : [
		'context'
	],
	#category : #'LLVM-IR-API'
}

{ #category : #'as yet unclassified' }
LLVMModuleRef >> addFunction: name type: functionType [
	^ self ffiCall: #(LLVMValueRef LLVMAddFunction(self, String name, LLVMTypeRef functionType)) library: LLVMC
]

{ #category : #accessing }
LLVMModuleRef >> context [

	^ context
]

{ #category : #accessing }
LLVMModuleRef >> context: anObject [

	context := anObject
]

{ #category : #'memory management' }
LLVMModuleRef >> primitiveDispose [
	^ self ffiCall: #(void LLVMDisposeModule(self)) library: LLVMC
]

{ #category : #writing }
LLVMModuleRef >> writeBitcodeToFileNamed: fileName [
	^ self ffiCall: #(int LLVMWriteBitcodeToFile(self, String fileName)) library: LLVMC
]
