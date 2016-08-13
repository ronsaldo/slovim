Class {
	#name : #SLVMInterferenceGraph,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #adding }
SLVMInterferenceGraph >> addNode: aNode [
	nodes add: aNode
]

{ #category : #initialization }
SLVMInterferenceGraph >> initialize [
	super initialize.
	nodes := OrderedCollection new.
	
]

{ #category : #accessing }
SLVMInterferenceGraph >> nodes [
	^ nodes
]
