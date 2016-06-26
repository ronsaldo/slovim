Class {
	#name : #SLVMInterferenceGraph,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #'Slovim-Core-RegisterAllocation'
}

{ #category : #'as yet unclassified' }
SLVMInterferenceGraph >> addNode: aNode [
	nodes add: aNode
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraph >> initialize [
	super initialize.
	nodes := OrderedCollection new.
	
]

{ #category : #accessing }
SLVMInterferenceGraph >> nodes [
	^ nodes
]
