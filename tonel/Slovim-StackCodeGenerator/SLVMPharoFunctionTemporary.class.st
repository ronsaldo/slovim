Class {
	#name : #SLVMPharoFunctionTemporary,
	#superclass : #SLVMETreeVisitor,
	#instVars : [
		'name',
		'type'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'as yet unclassified' }
SLVMPharoFunctionTemporary >> emitPushWith: aCodeGenerator [
	^ aCodeGenerator pushTemp: name
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionTemporary >> emitStoreStackTopWith: aCodeGenerator [
	^ aCodeGenerator storeTemp: name
]

{ #category : #accessing }
SLVMPharoFunctionTemporary >> name [
	^ name
]

{ #category : #accessing }
SLVMPharoFunctionTemporary >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMPharoFunctionTemporary >> type [
	^ type
]

{ #category : #accessing }
SLVMPharoFunctionTemporary >> type: anObject [
	type := anObject
]
