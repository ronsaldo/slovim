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

{ #category : #'as yet unclassified' }
SLVMUndefined >> accept: aVisitor [
	^ aVisitor visitUndefinedInstruction: self
]

{ #category : #printing }
SLVMUndefined >> mnemonic [
	^ 'undefined'
]

{ #category : #accessing }
SLVMUndefined >> type [
	^ type
]

{ #category : #accessing }
SLVMUndefined >> type: anObject [
	type := anObject
]
