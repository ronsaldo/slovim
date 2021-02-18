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
LLVMBuilderRef >> int: value toPtr: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildIntToPtr(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
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
LLVMBuilderRef >> ret: result [
	^ self ffiCall: #(LLVMValueRef LLVMBuildRet(self, LLVMValueRef result)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> retVoid [
	^ self ffiCall: #(LLVMValueRef LLVMBuildRetVoid(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> sext: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildSExt(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
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
LLVMBuilderRef >> trunc: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildTrunc(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> ui: value toFP: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildUIToFP(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> unreachable [
	^ self ffiCall: #(LLVMValueRef LLVMBuildCondBr(self)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMBuilderRef >> zext: value to: destType name: name [
	^ self ffiCall: #(LLVMValueRef LLVMBuildZExt(self, LLVMValueRef value, LLVMTypeRef destType, String name)) library: LLVMC
]
