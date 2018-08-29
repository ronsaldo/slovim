Class {
	#name : #SLVMPharoFunctionLocal,
	#superclass : #SLVMPharoFunctionTemp,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'code generation' }
SLVMPharoFunctionLocal >> emitPushUsingLowcodeWith: aCodeGenerator [
	type pushLocal: location usingLowcodeWith: aCodeGenerator
]

{ #category : #'code generation' }
SLVMPharoFunctionLocal >> emitPushWith: aCodeGenerator [
	vectorName ifNotNil: [ 
		^ aCodeGenerator pushRemoteTemp: name inVector: vectorName
	].

	^ aCodeGenerator pushTemp: name
]

{ #category : #'code generation' }
SLVMPharoFunctionLocal >> emitStoreAndPopStackTopUsingLowcodeWith: aCodeGenerator [
	type storeAndPopStackTopIntoLocal: location usingLowcodeWith: aCodeGenerator
]

{ #category : #'code generation' }
SLVMPharoFunctionLocal >> emitStoreStackTopWith: aCodeGenerator [
	vectorName ifNotNil: [ 
		^ aCodeGenerator storeRemoteTemp: name inVector: vectorName
	].

	^ aCodeGenerator storeTemp: name
]
