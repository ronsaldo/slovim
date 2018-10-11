"
I am an ordered set that is implemented by using a left-leaning red-black tree.
"
Class {
	#name : #SLVMOrderedSet,
	#superclass : #SLVMRedBlackTreeCollection,
	#category : #'Slovim-Core-Collections'
}

{ #category : #accessing }
SLVMOrderedSet >> first [
	^ self firstNode ifNotNil: [ :node | node value ]
]

{ #category : #accessing }
SLVMOrderedSet >> includes: aValue [
	^ (self searchKey: aValue from: root) isNotNil
]

{ #category : #accessing }
SLVMOrderedSet >> last [
	^ self lastNode ifNotNil: [ :node | node value ]
]
