Class {
	#name : #LLVMValueRef,
	#superclass : #LLVMRef,
	#category : #'LLVM-IR-API'
}

{ #category : #adding }
LLVMValueRef >> addCase: value destination: destination [
	^ self ffiCall: #(void LLVMAddCase(self, LLVMValueRef value, LLVMBasicBlockRef destination)) library: LLVMC
]

{ #category : #adding }
LLVMValueRef >> addClause: clause [
	^ self ffiCall: #(void LLVMAddClause(self, LLVMValueRef clause)) library: LLVMC
]

{ #category : #adding }
LLVMValueRef >> addIncomingValues: values blocks: blocks count: count [
	^ self ffiCall: #(void LLVMAddIncoming(self, void *values, void *blocks, uint count)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> appendBasicBlockNamed: blockName inContext: context [
	^ self ffiCall: #(LLVMBasicBlockRef LLVMAppendBasicBlockInContext(LLVMContextRef context, LLVMValueRef self, String blockName)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> asMetadata [
	^ self ffiCall: #(LLVMMetadataRef LLVMValueAsMetadata (self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> constBitCastTo: type [
	^ self ffiCall: #(LLVMValueRef LLVMConstBitCast(self, LLVMTypeRef type)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> constGEPIndices: indices count: count [
	^ self ffiCall: #(LLVMValueRef LLVMConstGEP(self, void *indices, uint count)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> constInBoundsGEPIndices: indices count: count [
	^ self ffiCall: #(LLVMValueRef LLVMConstInBoundsGEP(self, void *indices, uint count)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> constIntToPtr: type [
	^ self ffiCall: #(LLVMValueRef LLVMConstIntToPtr(self, LLVMTypeRef type)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> constPtrToInt: type [
	^ self ffiCall: #(LLVMValueRef LLVMConstPtrToInt(self, LLVMTypeRef type)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> getParam: index [
	^ self ffiCall: #(LLVMValueRef LLVMGetParam (self, uint index)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setAlignment: alignment [
	^ self ffiCall: #(void LLVMSetAlignment(self, uint alignment)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setCleanup: isCleanup [
	^ self ffiCall: #(void LLVMSetCleanup(self, bool isCleanup)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setDLLStorageClass: dllStorageClass [
	^ self ffiCall: #(void LLVMSetDLLStorageClass(self, uint dllStorageClass)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setGlobalConstant: isConstant [
	^ self ffiCall: #(void LLVMSetGlobalConstant(self, bool isConstant)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setGlobalInitializer: initialValue [
	^ self ffiCall: #(void LLVMSetInitializer(self, LLVMValueRef initialValue)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setLinkage: linkage [
	^ self ffiCall: #(void LLVMSetLinkage(self, uint linkage)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> setName: name [
	self setValueName: name size: name size
]

{ #category : #initialization }
LLVMValueRef >> setOrdering: ordering [
	^ self ffiCall: #(void LLVMSetOrdering(self, uint ordering)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setThreadLocalMode: threadLocalMode [
	^ self ffiCall: #(void LLVMSetThreadLocalMode(self, uint threadLocalMode)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMValueRef >> setValueName: name size: size [
	self ffiCall: #(void LLVMSetValueName2(self, String name, 	size_t size)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setVisibility: visibility [
	^ self ffiCall: #(void LLVMSetVisibility(self, uint visibility)) library: LLVMC
]

{ #category : #initialization }
LLVMValueRef >> setVolatile: isVolatile [
	^ self ffiCall: #(void LLVMSetVolatile(self, bool isVolatile)) library: LLVMC
]
