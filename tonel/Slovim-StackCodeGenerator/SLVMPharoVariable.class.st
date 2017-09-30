Class {
	#name : #SLVMPharoVariable,
	#superclass : #Object,
	#instVars : [
		'type'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'as yet unclassified' }
SLVMPharoVariable >> emitPushWith: aCodeGenerator [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMPharoVariable >> emitStoreStackTopWith: aCodeGenerator [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMPharoVariable >> type [
	^ type
]

{ #category : #accessing }
SLVMPharoVariable >> type: anObject [
	type := anObject
]
