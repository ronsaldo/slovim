"
I am an implementation of union-find for finding disjoint sets.
"
Class {
	#name : #SLVMDisjointSets,
	#superclass : #Object,
	#instVars : [
		'elements'
	],
	#category : #'Slovim-Core-Collections'
}

{ #category : #adding }
SLVMDisjointSets >> add: aValue [
	^ self elementForValue: aValue
]

{ #category : #adding }
SLVMDisjointSets >> addSet: aSet [
	| firstElement element |
	firstElement := nil.
	aSet do: [ :el |
		element := self add: el.
		firstElement ifNil: [
			firstElement := element
		] ifNotNil: [ 
			firstElement unionWith: element
		]
	].
	^ firstElement
]

{ #category : #adding }
SLVMDisjointSets >> addSets: sets [
	sets do: [ :s | self addSet: s ]
]

{ #category : #'as yet unclassified' }
SLVMDisjointSets >> elementForValue: aValue [
	^ elements at: aValue ifAbsentPut: [ SLVMDisjointSetElement new value: aValue ]
]

{ #category : #initialization }
SLVMDisjointSets >> initialize [
	super initialize.
	elements := Dictionary new.
]

{ #category : #testing }
SLVMDisjointSets >> is: x joinedWith: y [
	^ (self rootOrNilOf: x) == (self rootOrNilOf: y)
]

{ #category : #'as yet unclassified' }
SLVMDisjointSets >> join: x with: y [
	^ (self elementForValue: x) unionWith: (self elementForValue: y)
]

{ #category : #testing }
SLVMDisjointSets >> rootOrNilOf: value [
	^ elements at: value ifPresent: [ :element | element findRoot ] ifAbsent: [ nil ]
]

{ #category : #'as yet unclassified' }
SLVMDisjointSets >> sets [
	| disjointSets setRepresentative set |
	disjointSets := OrderedCollection new.
	
	elements valuesDo: [ :el | el setIndex: nil ].
	elements valuesDo: [ :el |
		setRepresentative := el findRoot.
		setRepresentative setIndex ifNil: [
			set := OrderedCollection new.
			disjointSets add: set.
			setRepresentative setIndex: disjointSets size
		] ifNotNil: [ :setIndex |
			set := disjointSets at: setIndex
		].
		set add: el value
	].

	^ disjointSets
]
