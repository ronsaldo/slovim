Class {
	#name : #LLVMContextRef,
	#superclass : #LLVMDisposableRef,
	#category : #'LLVM-IR-API'
}

{ #category : #operations }
LLVMContextRef class >> create [
	^ self primitiveCreate autoRelease; yourself
]

{ #category : #operations }
LLVMContextRef class >> primitiveCreate [
	^ self ffiCall: #(LLVMContextRef LLVMContextCreate()) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMContextRef >> constString: elements length: length dontNullTerminate: dontNullTerminate [
	^ self ffiCall: #(LLVMValueRef LLVMConstStringInContext(self, void *elements, uint length, bool dontNullTerminate)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMContextRef >> constStruct: constantValues count: count packed: packed [
	^ self ffiCall: #(LLVMValueRef LLVMConstStructInContext(self,
                                      void *constantValues,
                                      uint count, bool packed)) library: LLVMC
]

{ #category : #'module creation' }
LLVMContextRef >> createBuilder [
	^ self primitiveCreateBuilder
		context: self;
		autoRelease;
		yourself
]

{ #category : #accessing }
LLVMContextRef >> createEnumAttribute: kind value: value [
	^ self ffiCall: #(LLVMAttributeRef LLVMCreateEnumAttribute(self, uint kind, uint64 value)) library: LLVMC
]

{ #category : #'module creation' }
LLVMContextRef >> createModuleWithName: name [
	^ (self primitiveCreateModuleWithName: name)
		context: self;
		autoRelease;
		yourself
]

{ #category : #accessing }
LLVMContextRef >> createStructNamed: name [
	^ self ffiCall: #(LLVMTypeRef LLVMStructCreateNamed(self, String name)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> createStructWithElements: elements count: elementCount packed: packed [
	^ self ffiCall: #(LLVMTypeRef LLVMStructTypeInContext(self, void* elements, uint elementCount, bool packed)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> doubleType [
	^ self ffiCall: #(LLVMTypeRef LLVMDoubleTypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> floatType [
	^ self ffiCall: #(LLVMTypeRef LLVMFloatTypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> fp128Type [
	^ self ffiCall: #(LLVMTypeRef LLVMFP128TypeInContext(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMContextRef >> functionType: returnType args: params count: paramCount variadic: isVariadic [
	^ self ffiCall: #(LLVMTypeRef LLVMFunctionType(LLVMTypeRef returnType, void* params, 	uint paramCount, bool isVariadic)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMContextRef >> getMDKindForName: name len: nameLen [
	^ self ffiCall: #(uint LLVMGetMDKindIDInContext(self, char *name, uint nameLen)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> halfType [
	^ self ffiCall: #(LLVMTypeRef LLVMHalfTypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> int128Type [
	^ self ffiCall: #(LLVMTypeRef LLVMInt128TypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> int16Type [
	^ self ffiCall: #(LLVMTypeRef LLVMInt16TypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> int1Type [
	^ self ffiCall: #(LLVMTypeRef LLVMInt1TypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> int32Type [
	^ self ffiCall: #(LLVMTypeRef LLVMInt32TypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> int64Type [
	^ self ffiCall: #(LLVMTypeRef LLVMInt64TypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> int8Type [
	^ self ffiCall: #(LLVMTypeRef LLVMInt8TypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> intType: numBits [
	^ self ffiCall: #(LLVMTypeRef LLVMIntTypeInContext(self, uint numBits)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> labelType [
	^ self ffiCall: #(LLVMTypeRef LLVMLabelTypeInContext(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMContextRef >> mdNodeWith: elements count: count [
	^ self ffiCall: #(LLVMMetadataRef LLVMMDNodeInContext2(self, void *elements, size_t count)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMContextRef >> mdString: value slen: size [
	^ self ffiCall: #(LLVMMetadataRef LLVMMDStringInContext2(self, char *value, size_t size)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMContextRef >> metadataAsValue: metadata [
	^ self ffiCall: #(LLVMTypeRef LLVMMetadataAsValue(self, LLVMMetadataRef metadata)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> metadataType [
	^ self ffiCall: #(LLVMTypeRef LLVMMetadataTypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> ppcFP128Type [
	^ self ffiCall: #(LLVMTypeRef LLVMPPCFP128TypeInContext(self)) library: LLVMC
]

{ #category : #'module creation' }
LLVMContextRef >> primitiveCreateBuilder [
	^ self ffiCall: #(LLVMBuilderRef LLVMCreateBuilderInContext(self)) library: LLVMC
]

{ #category : #'module creation' }
LLVMContextRef >> primitiveCreateModuleWithName: name [
	^ self ffiCall: #(LLVMModuleRef LLVMModuleCreateWithNameInContext(String name, self)) library: LLVMC
]

{ #category : #'memory management' }
LLVMContextRef >> primitiveDispose [
	^ self ffiCall: #(void LLVMContextDispose(self)) library: LLVMC
]

{ #category : #'module creation' }
LLVMContextRef >> primitiveTemporaryMDNode: elements count: count [
	^ self ffiCall: #(LLVMMetadataRef LLVMTemporaryMDNode(self, void *elements, size_t count)) library: LLVMC
]

{ #category : #'module creation' }
LLVMContextRef >> temporaryMDNode: elements count: count [
	^ (self primitiveTemporaryMDNode: elements count: count)
		autoRelease;
		yourself
]

{ #category : #accessing }
LLVMContextRef >> voidType [
	^ self ffiCall: #(LLVMTypeRef LLVMVoidTypeInContext(self)) library: LLVMC
]

{ #category : #accessing }
LLVMContextRef >> x86fp80Type [
	^ self ffiCall: #(LLVMTypeRef LLVMX86FP80TypeInContext(self)) library: LLVMC
]
