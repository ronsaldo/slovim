Class {
	#name : #SLVMPharoCompilationModule,
	#superclass : #Object,
	#instVars : [
		'elements'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #adding }
SLVMPharoCompilationModule >> add: anElement [
	elements add: anElement
]

{ #category : #accessing }
SLVMPharoCompilationModule >> elements [
	^ elements
]

{ #category : #initialization }
SLVMPharoCompilationModule >> initialize [
	super initialize.
	elements := OrderedCollection new.
]
