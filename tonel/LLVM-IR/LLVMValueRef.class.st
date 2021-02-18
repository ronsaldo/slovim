Class {
	#name : #LLVMValueRef,
	#superclass : #LLVMRef,
	#category : #'LLVM-IR-API'
}

{ #category : #'as yet unclassified' }
LLVMValueRef >> appendBasicBlockNamed: blockName inContext: context [
	^ self ffiCall: #(LLVMBasicBlockRef LLVMAppendBasicBlockInContext(LLVMContextRef context, LLVMValueRef self, String blockName)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> asMetadata [
	^ self ffiCall: #(LLVMMetadataRef LLVMValueAsMetadata (self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> getParam: index [
	^ self ffiCall: #(LLVMValueRef LLVMGetParam (self, uint index)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> setName: name [
	self setValueName: name size: name size
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> setValueName: name size: size [
	self ffiCall: #(void LLVMSetValueName2(self, String name, 	size_t size)) library: LLVMC
]
