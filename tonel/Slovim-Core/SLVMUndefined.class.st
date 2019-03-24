Class {
	#name : #SLVMUndefined,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMUndefined class >> type: aType [
	^ self new type: aType
]

{ #category : #visitor }
SLVMUndefined >> accept: aVisitor [
	^ aVisitor visitUndefinedInstruction: self
]

{ #category : #testing }
SLVMUndefined >> isPureInstruction [
	^ true
]

{ #category : #testing }
SLVMUndefined >> isUndefined [
	^ true
]

{ #category : #printing }
SLVMUndefined >> mnemonic [
	^ #undefined
]

{ #category : #accessing }
SLVMUndefined >> type [
	^ type
]

{ #category : #accessing }
SLVMUndefined >> type: anObject [
	type := anObject
]
