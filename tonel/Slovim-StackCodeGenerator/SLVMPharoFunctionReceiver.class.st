Class {
	#name : #SLVMPharoFunctionReceiver,
	#superclass : #SLVMPharoVariable,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'code generation' }
SLVMPharoFunctionReceiver >> emitPushUsingLowcodeWith: aCodeGenerator [
	(type isPointerType and: [type isDynamicObjectPointerType not ]) ifTrue: [
		^ aCodeGenerator pushReceiver;
			lowcodeFirstFieldPointer
	].

	^ super emitPushUsingLowcodeWith: aCodeGenerator
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionReceiver >> emitPushWith: aCodeGenerator [
	^ aCodeGenerator pushReceiver
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionReceiver >> emitStoreStackTopWith: aCodeGenerator [
	self subclassResponsibility
]
