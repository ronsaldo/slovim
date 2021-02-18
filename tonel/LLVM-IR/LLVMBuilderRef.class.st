Class {
	#name : #LLVMBuilderRef,
	#superclass : #LLVMDisposableRef,
	#instVars : [
		'context',
		'module'
	],
	#category : #'LLVM-IR-API'
}

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> binOp: opcode left: left right: right name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildBinOp(self, int opcode, LLVMValueRef left, LLVMValueRef right, String name)) library: LLVMC
]

{ #category : #accessing }
LLVMBuilderRef >> context [

	^ context
]

{ #category : #accessing }
LLVMBuilderRef >> context: anObject [

	context := anObject
]

{ #category : #accessing }
LLVMBuilderRef >> module [

	^ module
]

{ #category : #accessing }
LLVMBuilderRef >> module: anObject [

	module := anObject
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> positionAtEndOf: basicBlock [
	^ self ffiCall: #(LLVMValueRef LLVMPositionBuilderAtEnd(self, LLVMBasicBlockRef basicBlock)) library: LLVMC
]

{ #category : #'memory management' }
LLVMBuilderRef >> primitiveDispose [
	^ self ffiCall: #(void LLVMDisposeBuilder(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> ret: result [
	^ self ffiCall: #(LLVMValueRef LLVMBuildRet(self, LLVMValueRef result)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> retVoid [
	^ self ffiCall: #(LLVMValueRef LLVMBuildRetVoid(self)) library: LLVMC
]
