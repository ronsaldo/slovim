"
I represent the metada of a Smalltalk package, along with class loading dependencies.

"
Class {
	#name : #SLVMModulePackage,
	#superclass : #SLVMObject,
	#instVars : [
		'elements',
		'name'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMModulePackage >> addElement: anElement [
	elements add: anElement
]

{ #category : #accessing }
SLVMModulePackage >> elements [
	^ elements
]

{ #category : #accessing }
SLVMModulePackage >> elements: anObject [
	elements := anObject
]

{ #category : #'code generation' }
SLVMModulePackage >> emitFor: module registrationWithAllocaBuilder: allocaBuilder codeBuilder: codeBuilder [
]

{ #category : #initialization }
SLVMModulePackage >> initialize [
	super initialize.
	
	elements := OrderedCollection new.
	
]

{ #category : #accessing }
SLVMModulePackage >> name [
	^ name
]

{ #category : #accessing }
SLVMModulePackage >> name: anObject [
	name := anObject
]
