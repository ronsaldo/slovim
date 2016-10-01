Class {
	#name : #SLVMLirModuleElement,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'visibility',
		'alignment'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirModuleElement >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMLirModuleElement >> alignment: anObject [
	alignment := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirModuleElement >> initialize [
	super initialize.
	alignment := 1.
]

{ #category : #testing }
SLVMLirModuleElement >> isExternal [
	^ false
]

{ #category : #testing }
SLVMLirModuleElement >> isModuleElement [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMLirModuleElement >> labelType [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMLirModuleElement >> section [
	^ self subclassResponsibility
]

{ #category : #accessing }
SLVMLirModuleElement >> visibility [
	^ visibility
]

{ #category : #accessing }
SLVMLirModuleElement >> visibility: anObject [
	visibility := anObject
]
