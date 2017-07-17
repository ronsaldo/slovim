Class {
	#name : #SLVMGetThisContext,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMGetThisContext class >> type: type [
	^ self new type: type
]

{ #category : #visitor }
SLVMGetThisContext >> accept: visitor [
	^ visitor visitGetThisContext: self
]

{ #category : #printing }
SLVMGetThisContext >> mnemonic [
	^ 'getThisContext'
]

{ #category : #accessing }
SLVMGetThisContext >> type [
	^ type
]

{ #category : #accessing }
SLVMGetThisContext >> type: anObject [
	type := anObject.
	self assert: type isDynamicObjectType.
	
]
