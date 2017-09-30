Class {
	#name : #SLVMPharoFunctionArgument,
	#superclass : #SLVMPharoFunctionTemp,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'as yet unclassified' }
SLVMPharoFunctionArgument >> emitPushWith: aCodeGenerator [
	^ aCodeGenerator pushTemp: name
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionArgument >> emitStoreStackTopWith: aCodeGenerator [
	self error: 'Cannot store into an argument.'
]
