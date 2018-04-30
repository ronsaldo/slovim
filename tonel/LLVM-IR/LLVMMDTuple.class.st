Class {
	#name : #LLVMMDTuple,
	#superclass : #LLVMMDNode,
	#instVars : [
		'elements'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'as yet unclassified' }
LLVMMDTuple class >> for: aModule rawElements: rawElements [
	^ (self for: aModule)
		rawElements: rawElements;
		yourself
]

{ #category : #adding }
LLVMMDTuple >> addElement: anElement [
	elements := elements copyWith: anElement
]

{ #category : #accessing }
LLVMMDTuple >> elements [
	^ elements
]

{ #category : #accessing }
LLVMMDTuple >> elements: anObject [
	elements := anObject
]

{ #category : #initialization }
LLVMMDTuple >> initialize [
	super initialize.
	elements := #()
	
]

{ #category : #printing }
LLVMMDTuple >> printContentOn: aStream [
	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		element printOn: aStream
	]
]

{ #category : #'as yet unclassified' }
LLVMMDTuple >> rawElements: rawElements [
	self elements: (rawElements collect: #asLLVMMetadata)
]
