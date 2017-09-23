"
I am a set the preserves the order of insertion of the elements.
"
Class {
	#name : #SLVMOrderedInsertionSet,
	#superclass : #Object,
	#instVars : [
		'insertionOrder',
		'set'
	],
	#category : #'Slovim-Core-Collections'
}

{ #category : #adding }
SLVMOrderedInsertionSet >> add: anElement [
	(set includes: anElement) ifTrue: [ ^ anElement ].
	set add: anElement.
	insertionOrder add: anElement.
	^ anElement
]

{ #category : #adding }
SLVMOrderedInsertionSet >> addAll: aCollection [
	aCollection do: [ :el | self add: el ]
]

{ #category : #converting }
SLVMOrderedInsertionSet >> asArray [
	^ insertionOrder asArray
]

{ #category : #accessing }
SLVMOrderedInsertionSet >> at: anIndex [
	^ insertionOrder at: anIndex
]

{ #category : #enumerating }
SLVMOrderedInsertionSet >> collect: aBlock [
	^ insertionOrder collect: aBlock
]

{ #category : #enumerating }
SLVMOrderedInsertionSet >> do: aBlock [
	^ insertionOrder do: aBlock
]

{ #category : #'gt-inspector-extension' }
SLVMOrderedInsertionSet >> gtInspectorItemsIn: composite [
	<gtInspectorPresentationOrder: 0>
	^ insertionOrder gtInspectorItemsIn: composite
]

{ #category : #testing }
SLVMOrderedInsertionSet >> ifEmpty: aBlock [
	^ set ifEmpty: aBlock
]

{ #category : #testing }
SLVMOrderedInsertionSet >> ifNotEmpty: aBlock [
	^ set ifNotEmpty: aBlock
]

{ #category : #initialization }
SLVMOrderedInsertionSet >> initialize [
	super initialize.
	insertionOrder := OrderedCollection new.
	set := Set new.
]

{ #category : #testing }
SLVMOrderedInsertionSet >> isEmpty [
	^ insertionOrder isEmpty
]

{ #category : #testing }
SLVMOrderedInsertionSet >> isNotEmpty [
	^ insertionOrder isNotEmpty
]

{ #category : #removing }
SLVMOrderedInsertionSet >> removeAll [
	insertionOrder removeAll.
	set removeAll.
]

{ #category : #enumerating }
SLVMOrderedInsertionSet >> select: aBlock [
	^ insertionOrder select: aBlock
]

{ #category : #enumerating }
SLVMOrderedInsertionSet >> select: aBlock thenCollect: collectBlock [
	^ insertionOrder select: aBlock thenCollect: collectBlock
]

{ #category : #accessing }
SLVMOrderedInsertionSet >> size [
	^ insertionOrder size
]
