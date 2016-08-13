Class {
	#name : #SLVMLirLabel,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'name'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #testing }
SLVMLirLabel >> isLabel [
	^ true
]

{ #category : #accessing }
SLVMLirLabel >> name [
	^ name
]

{ #category : #accessing }
SLVMLirLabel >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMLirLabel >> printOn: aStream [
	aStream nextPutAll: name; nextPut: $:
]
