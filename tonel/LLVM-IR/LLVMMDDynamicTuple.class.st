Class {
	#name : #LLVMMDDynamicTuple,
	#superclass : #LLVMMDNode,
	#instVars : [
		'elements'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #adding }
LLVMMDDynamicTuple >> addElement: anElement [
	elements add: anElement
]

{ #category : #initialization }
LLVMMDDynamicTuple >> initialize [
	super initialize.
	elements := OrderedCollection new.
]

{ #category : #printing }
LLVMMDDynamicTuple >> printContentOn: aStream [
	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		element printOn: aStream
	]
]
