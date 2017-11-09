Class {
	#name : #SLVMPharoFunctionLocal,
	#superclass : #SLVMPharoFunctionTemp,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'code generation' }
SLVMPharoFunctionLocal >> emitPushUsingLowcodeWith: aCodeGenerator [
	type pushLocal: location usingLowcodeWith: aCodeGenerator
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionLocal >> emitPushWith: aCodeGenerator [
	^ aCodeGenerator pushTemp: name
]

{ #category : #'code generation' }
SLVMPharoFunctionLocal >> emitStoreAndPopStackTopUsingLowcodeWith: aCodeGenerator [
	type storeAndPopStackTopIntoLocal: location usingLowcodeWith: aCodeGenerator
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionLocal >> emitStoreStackTopWith: aCodeGenerator [
	^ aCodeGenerator storeTemp: name
]
