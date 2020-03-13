Class {
	#name : #SLVMGetThisContext,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMGetThisContext class >> mnemonic [
	^ #getThisContext
]

{ #category : #'as yet unclassified' }
SLVMGetThisContext class >> type: type [
	^ self new type: type
]

{ #category : #visitor }
SLVMGetThisContext >> accept: visitor [
	^ visitor visitGetThisContext: self
]

{ #category : #testing }
SLVMGetThisContext >> isDynamicObjectReferenceCreator [
	^ true
]

{ #category : #testing }
SLVMGetThisContext >> isGetThisContext [
	^ true
]

{ #category : #testing }
SLVMGetThisContext >> isPureInstruction [
	^ true
]

{ #category : #accessing }
SLVMGetThisContext >> type [
	^ type
]

{ #category : #accessing }
SLVMGetThisContext >> type: anObject [
	type := anObject.
	self assert: (type isDynamicObjectPointerType or: [type isPointerType]).
	
]
