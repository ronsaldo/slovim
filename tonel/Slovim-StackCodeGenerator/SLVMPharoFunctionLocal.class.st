Class {
	#name : #SLVMPharoFunctionLocal,
	#superclass : #SLVMPharoFunctionTemp,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'as yet unclassified' }
SLVMPharoFunctionLocal >> emitPushWith: aCodeGenerator [
	^ aCodeGenerator pushTemp: name
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionLocal >> emitStoreStackTopWith: aCodeGenerator [
	^ aCodeGenerator storeTemp: name
]
