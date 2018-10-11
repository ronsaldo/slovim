Class {
	#name : #SLVMRedBlackTreeNodeTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMRedBlackTreeNodeTest >> testWithValue [
	| node |
	node := SLVMRedBlackTreeNode value: 1.
	self assert: node value equals: 1.
	self assert: node isLeaf
]
