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
	self addQuiet: anInstruction.
	self instructionAdded: anInstruction
]

{ #category : #adding }
SLVMBasicBlock >> add: anInstruction after: instructionPoint [
	instructionPoint ifNil: [ ^ self addFirst: instructionPoint ].
	self halt.
]

{ #category : #adding }
SLVMBasicBlock >> addFirst: anInstruction [ 
	instructions ifNotEmpty: [
		instructions first previousInstruction: anInstruction.
		anInstruction nextInstruction: instructions first.
		anInstruction previousInstruction: nil.
	].

	instructions addFirst: anInstruction.
	self instructionAdded: anInstruction
]

{ #category : #adding }
SLVMBasicBlock >> addPredecessor: aBasicBlock [
	predecessors add: aBasicBlock
]

{ #category : #adding }
SLVMBasicBlock >> addQuiet: anInstruction [ 
	instructions ifNotEmpty: [
		instructions last nextInstruction: anInstruction.
		anInstruction previousInstruction: instructions last.
		anInstruction nextInstruction: nil.
	].

	instructions add: anInstruction.
	anInstruction block: self
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

{ #category : #accessing }
SLVMBasicBlock >> firstInstruction [
	^ instructions first
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

{ #category : #adding }
SLVMBasicBlock >> instructionAdded: anInstruction [ 
	anInstruction block: self.
	anInstruction isTerminator ifTrue: [
		self computeSuccessors
	].
]

{ #category : #'successor sequences' }
SLVMBasicBlock >> instructionsDo: aBlock [
	instructions do: aBlock
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

{ #category : #'as yet unclassified' }
SLVMBasicBlock >> phiInstructionsDo: aBlock [
	self instructionsDo: [:ins |
		ins isPhi ifFalse: [ ^ self ].
		aBlock value: ins
	]
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
	anInstruction previousInstruction ifNotNil: [ 
		anInstruction previousInstruction nextInstruction: anInstruction nextInstruction
	].

	anInstruction nextInstruction ifNotNil: [ 
		anInstruction nextInstruction previousInstruction: anInstruction previousInstruction
	].

	instructions remove: anInstruction.
	anInstruction block: nil.

]

{ #category : #adding }
SLVMBasicBlock >> removeChain: anInstructionChain [ 
	| current |
	current := anInstructionChain.
	[ current isNil ] whileFalse: [
		instructions remove: current.
		current block: nil.
		current := current nextInstruction
	].
	
]

{ #category : #adding }
SLVMBasicBlock >> setChain: anInstructionChain [ 
	| current |
	instructions removeAll.
	current := anInstructionChain.
	[ current isNil ] whileFalse: [
		instructions add: current.
		self instructionAdded: current.
		current := current nextInstruction
	].
	
]

{ #category : #accessing }
SLVMBasicBlock >> successors [
	^ successors
]

{ #category : #accessing }
SLVMBasicBlock >> successors: anObject [
	successors := anObject
]
