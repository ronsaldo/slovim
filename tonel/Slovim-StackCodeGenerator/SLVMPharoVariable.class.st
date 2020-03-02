Class {
	#name : #SLVMPharoVariable,
	#superclass : #Object,
	#instVars : [
		'type'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'code generation' }
SLVMPharoVariable >> emitPushUsingLowcodeWith: aCodeGenerator [
	self emitPushWith: aCodeGenerator.
	type isDynamicObjectPointerType ifFalse: [
		^ type fromOopUsingLowcodeWith: aCodeGenerator
	].

	^ nil
]

{ #category : #'code generation' }
SLVMPharoVariable >> emitPushWith: aCodeGenerator [
	self subclassResponsibility
]

{ #category : #'code generation' }
SLVMPharoVariable >> emitStoreAndPopStackTopUsingLowcodeWith: aCodeGenerator [
	self assert: type isDynamicObjectPointerType.
	self emitStoreStackTopWith: aCodeGenerator.
	aCodeGenerator popTop
]

{ #category : #'code generation' }
SLVMPharoVariable >> emitStoreStackTopWith: aCodeGenerator [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMPharoVariable >> storeAndPopValue: value usingLowcodeWith: functionCodeGenerator [ 
	^ self storeAndPopValue: value with: functionCodeGenerator
]

{ #category : #'as yet unclassified' }
SLVMPharoVariable >> storeAndPopValue: value with: functionCodeGenerator [
	functionCodeGenerator visitExpression: value.
	functionCodeGenerator storeAndPopStackTopIntoVariable: self.
]

{ #category : #accessing }
SLVMPharoVariable >> type [
	^ type
]

{ #category : #accessing }
SLVMPharoVariable >> type: anObject [
	type := anObject
]
