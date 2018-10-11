"
I am a node in a red-black tree whose values are associations. I override the key methods to use the key from the association for comparisons instead of the association itself.
"
Class {
	#name : #SLVMRedBlackTreeAssociationNode,
	#superclass : #SLVMRedBlackTreeNode,
	#category : #'Slovim-Core-Collections'
}

{ #category : #accessing }
SLVMRedBlackTreeAssociationNode >> key [
	^ value key
]
