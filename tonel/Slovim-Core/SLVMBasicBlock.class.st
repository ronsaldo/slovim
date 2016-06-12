Class {
	#name : #SLVMBasicBlock,
	#superclass : #SLVMObject,
	#instVars : [
		'index',
		'postOrderIndex',
		'preOrderIndex',
		'name',
		'function',
		'instructions',
		'predecessors',
		'successors',
		'immediateDominator',
		'dominanceFrontier'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMBasicBlock >> add: anInstruction [ 
	instructions add: anInstruction.
	anInstruction block: self.
	anInstruction isTerminator ifTrue: [
		self computeSuccessors
	].
]

{ #category : #adding }
SLVMBasicBlock >> addPredecessor: aBasicBlock [
	predecessors add: aBasicBlock
]

{ #category : #adding }
SLVMBasicBlock >> computeSuccessors [
	successors := instructions last successors.
	successors do: [ :suc | suc addPredecessor: self]

]

{ #category : #accessing }
SLVMBasicBlock >> dominanceFrontier [
	^ dominanceFrontier
]

{ #category : #accessing }
SLVMBasicBlock >> dominanceFrontier: anObject [
	dominanceFrontier := anObject
]

{ #category : #printing }
SLVMBasicBlock >> fullPrintOn: aStream [
	aStream print: self; nextPut: $:.
	aStream space.
	self printArray: predecessors on: aStream.
	aStream space.
	self printArray: successors on: aStream.
	aStream cr.
	instructions do: [ :ins | aStream tab. ins fullPrintOn: aStream. aStream cr ]
]

{ #category : #accessing }
SLVMBasicBlock >> function [
	^ function
]

{ #category : #accessing }
SLVMBasicBlock >> function: anObject [
	function := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> immediateDominator [
	^ immediateDominator
]

{ #category : #accessing }
SLVMBasicBlock >> immediateDominator: anObject [
	immediateDominator := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> index [
	^ index
]

{ #category : #accessing }
SLVMBasicBlock >> index: anObject [
	index := anObject
]

{ #category : #initialization }
SLVMBasicBlock >> initialize [
	super initialize.
	instructions := OrderedCollection new.
	predecessors := Set new.
	successors := #()
]

{ #category : #accessing }
SLVMBasicBlock >> instructions [
	^ instructions
]

{ #category : #accessing }
SLVMBasicBlock >> instructions: anObject [
	instructions := anObject
]

{ #category : #testing }
SLVMBasicBlock >> isEmpty [
	^ instructions isEmpty
]

{ #category : #testing }
SLVMBasicBlock >> isLastTerminator [
	^ self isEmpty not and: [ self lastInstruction isTerminator ]
]

{ #category : #accessing }
SLVMBasicBlock >> lastInstruction [
	^ instructions last
]

{ #category : #accessing }
SLVMBasicBlock >> name [
	^ name
]

{ #category : #accessing }
SLVMBasicBlock >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> numberOfInstructions [
	^ instructions size
]

{ #category : #accessing }
SLVMBasicBlock >> postOrderIndex [
	^ postOrderIndex
]

{ #category : #accessing }
SLVMBasicBlock >> postOrderIndex: anObject [
	postOrderIndex := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> preOrderIndex [
	^ preOrderIndex
]

{ #category : #accessing }
SLVMBasicBlock >> preOrderIndex: anObject [
	preOrderIndex := anObject
]

{ #category : #accessing }
SLVMBasicBlock >> predecessors [
	^ predecessors
]

{ #category : #accessing }
SLVMBasicBlock >> predecessors: anObject [
	predecessors := anObject
]

{ #category : #printing }
SLVMBasicBlock >> printArray: anArray on: aStream [
	aStream nextPut: $[; space.
	anArray do: [ :el |
		 aStream print: el; space].
	aStream nextPut: $].
]

{ #category : #printing }
SLVMBasicBlock >> printOn: aStream [
	aStream nextPutAll: name; nextPut: $@; print: index
]

{ #category : #adding }
SLVMBasicBlock >> remove: anInstruction [ 
	instructions remove: anInstruction.
	anInstruction block: nil.

]

{ #category : #accessing }
SLVMBasicBlock >> successors [
	^ successors
]

{ #category : #accessing }
SLVMBasicBlock >> successors: anObject [
	successors := anObject
]
