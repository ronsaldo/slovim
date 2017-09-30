Class {
	#name : #SLVMPharoLiteralVariable,
	#superclass : #SLVMPharoVariable,
	#instVars : [
		'binding'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #accessing }
SLVMPharoLiteralVariable >> binding [
	^ binding
]

{ #category : #accessing }
SLVMPharoLiteralVariable >> binding: anObject [
	binding := anObject
]

{ #category : #'as yet unclassified' }
SLVMPharoLiteralVariable >> emitPushWith: aCodeGenerator [
	^ aCodeGenerator pushLiteralVariable: binding
]

{ #category : #'as yet unclassified' }
SLVMPharoLiteralVariable >> emitStoreStackTopWith: aCodeGenerator [
	aCodeGenerator storeIntoLiteralVariable: binding
]
