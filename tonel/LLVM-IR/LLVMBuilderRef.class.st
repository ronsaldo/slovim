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
LLVMBuilderRef >> addrSpaceCast: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildAddrSpaceCast(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> alloca: type name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildAlloca(self, LLVMTypeRef type, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> atomicPointer: pointer cmp: comparisonValue xchg: newValue successOrdering: successOrdering failureOrdering: failureOrdering singleThread: singleThread [
	^ self ffiCall: #(LLVMValueRef LLVMBuildAtomicCmpXchg(self, LLVMValueRef pointer,
                                    LLVMValueRef comparisonValue, LLVMValueRef newValue,
                                    uint successOrdering,
                                    uint failureOrdering,
                                    bool singleThread)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> atomicRMW: op pointer: pointer value: value ordering: ordering singleThread: singleThread [
	^ self ffiCall: #(LLVMValueRef LLVMBuildAtomicRMW(self, uint op,
                                LLVMValueRef pointer, LLVMValueRef value,
                                uint ordering,
                                bool singleThread)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> binOp: opcode left: left right: right name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildBinOp(self, int opcode, LLVMValueRef left, LLVMValueRef right, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> bitCast: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildBitCast(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> branch: destination [
	^ self ffiCall: #(LLVMValueRef LLVMBuildBr(self, LLVMBasicBlockRef destination)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> call: function arguments: arguments count: count name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildCall(self, LLVMValueRef function, void *arguments, uint count, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> condition: condition branch: trueDestination else: falseDestination [
	^ self ffiCall: #(LLVMValueRef LLVMBuildCondBr(self, LLVMValueRef condition, LLVMBasicBlockRef trueDestination, LLVMBasicBlockRef falseDestination)) library: LLVMC
]

{ #category : #accessing }
LLVMBuilderRef >> context [

	^ context
]

{ #category : #accessing }
LLVMBuilderRef >> context: anObject [

	context := anObject
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> extract: vector elementAt: index name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildExtractElement(self, LLVMValueRef vector,
                                   LLVMValueRef index, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> extract: aggregate valueAt: index name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildExtractValue(self, LLVMValueRef aggregate,
                                   uint index, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> fcmp: opcode left: left right: right name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildFCmp(self, int opcode, LLVMValueRef left, LLVMValueRef right, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> fp: value toSI: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildFPToSI(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> fp: value toUI: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildFPToUI(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> fpExt: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildFPExt(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> fpTrunc: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildFPTrunc(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> gepPointer: pointer indices: indices numIndices: numIndices name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildGEP(self, LLVMValueRef pointer, void *indices, uint numIndices, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> icmp: opcode left: left right: right name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildICmp(self, int opcode, LLVMValueRef left, LLVMValueRef right, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> insert: vector element: element at: index name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildInsertElement(self, LLVMValueRef vector, LLVMValueRef element, LLVMValueRef index, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> insert: aggregate value: value at: index name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildInsertValue(self, LLVMValueRef aggregate, LLVMValueRef value, uint index, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> int: value toPtr: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildIntToPtr(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> invoke: function arguments: arguments count: count thenBlock: thenBlock catchBlock: catchBlock name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildInvoke(self, LLVMValueRef function, void *arguments, uint count, LLVMBasicBlockRef thenBlock, LLVMBasicBlockRef catchBlock, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> landingPath: type personalityFunction: personalityFunction numClauses: numClauses name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildLandingPad(self, LLVMTypeRef type,
                                 LLVMValueRef personalityFunction, uint numClauses,
                                 String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> load: pointer name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildLoad(self, LLVMValueRef pointer, String name)) library: LLVMC
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
LLVMBuilderRef >> phi: type name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildPhi(self, LLVMTypeRef type, String name)) library: LLVMC
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
LLVMBuilderRef >> ptr: value toInt: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildPtrToInt(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> resume: value [
	^ self ffiCall: #(LLVMValueRef LLVMBuildResume(self, LLVMValueRef value)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> ret: result [
	^ self ffiCall: #(LLVMValueRef LLVMBuildRet(self, LLVMValueRef result)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> retVoid [
	^ self ffiCall: #(LLVMValueRef LLVMBuildRetVoid(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> select: condition trueValue: trueValue falseValue: falseValue name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildSelect(self, LLVMValueRef condition, LLVMValueRef trueValue, LLVMValueRef falseValue, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> setCurrentDebugLocation: debugLocation [
	^ self ffiCall: #(void LLVMSetCurrentDebugLocation2(self, LLVMMetadataRef debugLocation)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> sext: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildSExt(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> shuffle: left with: right mask: mask name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildShuffleVector(self, LLVMValueRef left, LLVMValueRef right, LLVMValueRef mask, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> si: value toFP: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildSIToFP(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> store: value pointer: pointer [
	^ self ffiCall: #(LLVMValueRef LLVMBuildStore(self, LLVMValueRef value, LLVMValueRef pointer)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> switch: value default: defaultDestination numCases: numCases [
	^ self ffiCall: #(LLVMValueRef LLVMBuildSwitch(self, LLVMValueRef value, LLVMBasicBlockRef defaultDestination, uint numCases)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> trunc: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildTrunc(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> ui: value toFP: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildUIToFP(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> unreachable [
	^ self ffiCall: #(LLVMValueRef LLVMBuildUnreachable(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> zext: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildZExt(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]
