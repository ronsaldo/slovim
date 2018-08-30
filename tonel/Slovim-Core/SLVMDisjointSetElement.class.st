"
I am an element in the union-find disjoint set data structure.
"
Class {
	#name : #SLVMDisjointSetElement,
	#superclass : #Object,
	#instVars : [
		'parent',
		'value',
		'rank',
		'setIndex'
	],
	#category : #'Slovim-Core-Collections'
}

{ #category : #'as yet unclassified' }
SLVMDisjointSetElement >> findRoot [
	parent ~~ self ifTrue: [
		parent := parent findRoot.
	].

	^ parent
]

{ #category : #initialization }
SLVMDisjointSetElement >> initialize [
	super initialize.
	parent := self.
	rank := 0.
	
]

{ #category : #accessing }
SLVMDisjointSetElement >> parent [
	^ parent
]

{ #category : #accessing }
SLVMDisjointSetElement >> parent: anObject [
	parent := anObject
]

{ #category : #accessing }
SLVMDisjointSetElement >> rank [
	^ rank
]

{ #category : #accessing }
SLVMDisjointSetElement >> rank: anObject [
	rank := anObject
]

{ #category : #accessing }
SLVMDisjointSetElement >> setIndex [
	^ setIndex
]

{ #category : #accessing }
SLVMDisjointSetElement >> setIndex: anObject [
	setIndex := anObject
]

{ #category : #'as yet unclassified' }
SLVMDisjointSetElement >> unionWith: other [
	| xRoot yRoot tmp |
	xRoot := self findRoot.
	yRoot := other findRoot.
	
	xRoot == yRoot ifTrue: [ ^ self ].
	xRoot rank < yRoot rank ifTrue: [ 
		tmp := xRoot.
		xRoot := yRoot.
		yRoot := tmp
	].

	yRoot parent: xRoot.
	xRoot rank = yRoot rank ifTrue: [
		xRoot rank: xRoot rank + 1
	].

	^ xRoot
	
]

{ #category : #accessing }
SLVMDisjointSetElement >> value [
	^ value
]

{ #category : #accessing }
SLVMDisjointSetElement >> value: anObject [
	value := anObject
]
