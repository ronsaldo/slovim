Class {
	#name : #LLVMMetadataRef,
	#superclass : #LLVMDisposableRef,
	#category : #'LLVM-IR-API'
}

{ #category : #'as yet unclassified' }
LLVMMetadataRef >> getVariableFromGlobalExpression [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIGlobalVariableExpressionGetVariable(self)) library: LLVMC

]

{ #category : #'memory management' }
LLVMMetadataRef >> primitiveDispose [
	^ self ffiCall: #(void LLVMDisposeTemporaryMDNode(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMMetadataRef >> primitiveReplaceAllUsesWith: replacement [
	^ self ffiCall: #(void LLVMMetadataReplaceAllUsesWith(self, LLVMMetadataRef replacement)) library: LLVMC

]

{ #category : #'as yet unclassified' }
LLVMMetadataRef >> replaceAllUsesWith: replacement [
	self primitiveReplaceAllUsesWith: replacement.
	
	self class finalizationRegistry remove: self.
	handle := nil
]
