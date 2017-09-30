Class {
	#name : #SLVMPharoFunctionReceiver,
	#superclass : #SLVMPharoVariable,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'as yet unclassified' }
SLVMPharoFunctionReceiver >> emitPushWith: aCodeGenerator [
	^ aCodeGenerator pushReceiver
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionReceiver >> emitStoreStackTopWith: aCodeGenerator [
	self subclassResponsibility
]
