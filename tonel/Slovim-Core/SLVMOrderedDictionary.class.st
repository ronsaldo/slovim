"
I am an ordered dictionary that is implemented by using a left-leaning red-black tree.
"
Class {
	#name : #SLVMOrderedDictionary,
	#superclass : #SLVMRedBlackTreeCollection,
	#category : #'Slovim-Core-Collections'
}

{ #category : #adding }
SLVMOrderedDictionary >> add: anAssociation [
	root := self insertKey: anAssociation key value: anAssociation from: root.
	root color: Black
]

{ #category : #adding }
SLVMOrderedDictionary >> at: key [
	^ self at: key ifAbsent: [self errorKeyNotFound: key]
]

{ #category : #adding }
SLVMOrderedDictionary >> at: key ifAbsent: ifAbsentBlock [
	| node |
	node := self searchKey: key from: root.
	^ node ifNil: ifAbsentBlock value ifNotNil: [ node value value ]
]

{ #category : #adding }
SLVMOrderedDictionary >> at: aKey put: aValue [
	self add: aKey -> aValue.
	^ aValue
]

{ #category : #accessing }
SLVMOrderedDictionary >> do: aBlock [
	root ifNotNil: [ root do: [:association | aBlock value: association] ]
]

{ #category : #adding }
SLVMOrderedDictionary >> errorKeyNotFound: aKey [
	KeyNotFound signalFor: aKey
]

{ #category : #accessing }
SLVMOrderedDictionary >> first [
	^ self firstNode ifNotNil: [ :node | node value ]
]

{ #category : #testing }
SLVMOrderedDictionary >> includesKey: aValue [
	^ (self searchKey: aValue from: root) isNotNil
]

{ #category : #accessing }
SLVMOrderedDictionary >> keysDo: aBlock [
	root ifNotNil: [ root do: [:association | aBlock value: association key] ]
]

{ #category : #accessing }
SLVMOrderedDictionary >> last [
	^ self lastNode ifNotNil: [ :node | node value ]
]

{ #category : #adding }
SLVMOrderedDictionary >> nodeSpecies [
	^ SLVMRedBlackTreeAssociationNode
]

{ #category : #removing }
SLVMOrderedDictionary >> remove: oldObject ifAbsent: ifAbsentBlock [
	(self searchKey: oldObject key from: root) ifNil: [
		^ ifAbsentBlock value
	].

	self deleteKey: oldObject key.
	^ oldObject
]

{ #category : #removing }
SLVMOrderedDictionary >> removeKey: key [ 
	"Remove key from the receiver.
	If key is not in the receiver, notify an error."

	^ self removeKey: key ifAbsent: [self errorKeyNotFound: key]
]

{ #category : #removing }
SLVMOrderedDictionary >> removeKey: key ifAbsent: ifAbsentBlock [
	| oldValue |
	^ (self searchKey: key from: root) ifNil: [
		ifAbsentBlock value
	] ifNotNil: [ :oldNode |
		oldValue := oldNode value value.
		self deleteKey: key.
		^ oldValue
	]
]

{ #category : #accessing }
SLVMOrderedDictionary >> valuesDo: aBlock [
	root ifNotNil: [ root do: [:association | aBlock value: association value] ]
]
