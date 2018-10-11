"
I am a node in a red-black tree.

value: my value.
color: false for black, true for red.

"
Class {
	#name : #SLVMRedBlackTreeNode,
	#superclass : #Object,
	#instVars : [
		'value',
		'left',
		'right',
		'color'
	],
	#category : #'Slovim-Core-Collections'
}

{ #category : #accessing }
SLVMRedBlackTreeNode class >> value: aValue color: aColor [
	^ self new value: aValue; color: aColor; yourself
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> childrenNodes [
	| result |
	result := #().
	left ifNotNil: [ result := result , { left } ].
	right ifNotNil: [ result := result , { right } ].
	^ result
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> color [
	^ color
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> color: anObject [
	color := anObject
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> do: aBlock [
	left ifNotNil: [ left do: aBlock ].
	aBlock value: value.
	right ifNotNil: [ right do: aBlock ].

]

{ #category : #testing }
SLVMRedBlackTreeNode >> isLeaf [
	^ left == nil and: [ right == nil ]
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> key [
	^ value
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> left [
	^ left
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> left: anObject [
	left := anObject
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> printOn: aStream [
	aStream print: (color ifTrue:[#red] ifFalse: [#black]); space; print: value
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> right [
	^ right
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> right: anObject [
	right := anObject
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> value [
	^ value
]

{ #category : #accessing }
SLVMRedBlackTreeNode >> value: anObject [
	value := anObject
]
