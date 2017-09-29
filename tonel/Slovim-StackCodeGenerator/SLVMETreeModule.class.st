Class {
	#name : #SLVMETreeModule,
	#superclass : #Object,
	#instVars : [
		'elements'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #adding }
SLVMETreeModule >> add: anElement [
	elements add: anElement
]

{ #category : #accessing }
SLVMETreeModule >> elements [
	^ elements
]

{ #category : #printing }
SLVMETreeModule >> fullPrintOn: out [
	elements do: [ :el | el fullPrintOn: out. out cr ]
]

{ #category : #printing }
SLVMETreeModule >> fullPrintText [
	^ SLVMPrintingTextStream fullPrintString: self
]

{ #category : #'gt-inspector-extension' }
SLVMETreeModule >> gtInspectorModuleText: composite [
	<gtInspectorPresentationOrder: 1>
	^ (composite text)
		title: 'Assembly Module';
		format: #fullPrintText
]

{ #category : #initialization }
SLVMETreeModule >> initialize [
	super initialize.
	elements := OrderedCollection new.
]
