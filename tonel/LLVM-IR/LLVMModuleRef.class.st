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

{ #category : #'as yet unclassified' }
LLVMModuleRef >> addGlobal: name type: type [
	^ self ffiCall: #(LLVMValueRef LLVMAddGlobal(self, LLVMTypeRef type, String name)) library: LLVMC
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
LLVMModuleRef >> printToFileNamed: fileName [
	| buffer result errorMessage |
	buffer := ExternalAddress new.
	[ 
		result := self printToFileNamed: fileName errorMessage: buffer.
	] ensure: [
		buffer isNil ifFalse: [ 
			errorMessage := buffer readStringUTF8.
			LLVMC uniqueInstance disposeMessage: buffer
		]
	].

	result ifTrue: [
		self error: errorMessage
	]

]

{ #category : #writing }
LLVMModuleRef >> printToFileNamed: fileName errorMessage: errorMessage [
	^ self ffiCall: #(bool LLVMPrintModuleToFile(self, String fileName, char **errorMessage)) library: LLVMC
]

{ #category : #'as yet unclassified' }
LLVMModuleRef >> setTarget: triple [
	^ self ffiCall: #(void LLVMSetTarget(self, String triple)) library: LLVMC
]

{ #category : #writing }
LLVMModuleRef >> verifyModule [
	| buffer result errorMessage |
	buffer := ExternalAddress new.
	[ 
		result := self verifyModuleWithFailureAction: LLVMReturnStatusAction outMessage: buffer.
	] ensure: [
		buffer isNil ifFalse: [ 
			errorMessage := buffer readStringUTF8.
			LLVMC uniqueInstance disposeMessage: buffer
		]
	].

	result ifTrue: [
		self error: errorMessage
	]

]

{ #category : #writing }
LLVMModuleRef >> verifyModuleWithFailureAction: failureAction outMessage: outMessage [
	^ self ffiCall: #(bool LLVMVerifyModule(self, uint failureAction, char **outMessage)) library: LLVMC
]

{ #category : #writing }
LLVMModuleRef >> writeBitcodeToFileNamed: fileName [
	^ self ffiCall: #(int LLVMWriteBitcodeToFile(self, String fileName)) library: LLVMC
]
