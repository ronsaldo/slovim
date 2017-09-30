"
I am a module that uses expression trees as an intermediate representation for code.
"
Class {
	#name : #SLVMETreeModule,
	#superclass : #Object,
	#instVars : [
		'compilationTarget',
		'elements'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #adding }
SLVMETreeModule >> add: anElement [
	elements add: anElement
]

{ #category : #converting }
SLVMETreeModule >> asFinalModule [
	^ (compilationTarget finalTargetCodeGeneratorClass new
		compilationTarget: compilationTarget)
			translateModule: self
]

{ #category : #accessing }
SLVMETreeModule >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMETreeModule >> compilationTarget: anObject [
	compilationTarget := anObject
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
