Class {
	#name : #LLVMTypeRef,
	#superclass : #LLVMRef,
	#category : #'LLVM-IR-API'
}

{ #category : #'as yet unclassified' }
LLVMTypeRef >> arrayWithElements: elementCount [
	^ self ffiCall: #(LLVMTypeRef LLVMArrayType(self, uint elementCount)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> constArray: constantValues count: count [
	^ self ffiCall: #(LLVMValueRef LLVMConstArray(self, void *constantValues, uint count)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> constInt: value signExtend: signExtend [
	^ self ffiCall: #(LLVMValueRef LLVMConstInt(self, ulonglong value, bool signExtend)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> constIntString: text size: textSize radix: radix [
	^ self ffiCall: #(LLVMValueRef LLVMConstIntOfStringAndSize(self, char* text, uint textSize, uint8 radix)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> constPointerNull [
	^ self ffiCall: #(LLVMValueRef LLVMConstPointerNull(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> constReal: value [
	^ self ffiCall: #(LLVMValueRef LLVMConstReal(self, double value)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> constStruct: constantValues count: count [
	^ self ffiCall: #(LLVMValueRef LLVMConstNamedStruct(self, void *constantValues, uint count)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> constVector: constantValues count: count [
	^ self ffiCall: #(LLVMValueRef LLVMConstVector(void *constantValues, uint count)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> getUndef [
	^ self ffiCall: #(LLVMValueRef LLVMGetUndef(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> pointerForAddressSpace: addressSpace [
	^ self ffiCall: #(LLVMTypeRef LLVMPointerType(self, uint addressSpace)) library: LLVMC
]

{ #category : #initialization }
LLVMTypeRef >> setStructElements: elements count: elementCount packed: packed [
	^ self ffiCall: #(void LLVMStructSetBody(self, void* elements, uint elementCount, bool packed)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMTypeRef >> vectorWithElements: elementCount [
	^ self ffiCall: #(LLVMTypeRef LLVMVectorType(self, uint elementCount)) library: LLVMC
]
