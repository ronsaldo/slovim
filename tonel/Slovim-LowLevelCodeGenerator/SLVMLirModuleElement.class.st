Class {
	#name : #SLVMLirModuleElement,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'visibility'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

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
