Class {
	#name : #SLVMBasicBlock,
	#superclass : #SLVMObject,
	#instVars : [
		'index',
		'postOrderIndex',
		'preOrderIndex',
		'name',
		'function',
		'firstInstruction',
		'lastInstruction',
		'numberOfInstructions',
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
SLVMBasicBlock >> add: anInstruction before: instructionPoint [
	instructionPoint ifNil: [ ^ self addFirst: instructionPoint ].
	
	self assert: anInstruction previousInstruction isNil.
	self assert: anInstruction nextInstruction isNil.
	
	"Link the previous"
	anInstruction previousInstruction: instructionPoint previousInstruction.
	anInstruction previousInstruction ifNotNil: [ 
		anInstruction previousInstruction nextInstruction: anInstruction
	] ifNil: [ 
		firstInstruction := anInstruction.
	].

	"Link the next"
	anInstruction nextInstruction: instructionPoint.
	instructionPoint previousInstruction: anInstruction.
	
	numberOfInstructions := numberOfInstructions + 1.
	self instructionAdded: anInstruction
]

{ #category : #adding }
SLVMBasicBlock >> addFirst: anInstruction [
	self assert: anInstruction previousInstruction isNil.
	self assert: anInstruction nextInstruction isNil.
	firstInstruction ifNil: [
		firstInstruction := lastInstruction := anInstruction.
		numberOfInstructions := 1.
	] ifNotNil: [
		firstInstruction previousInstruction: anInstruction.
		anInstruction nextInstruction: firstInstruction.
		firstInstruction := anInstruction.
		numberOfInstructions ifNotNil: [ numberOfInstructions := numberOfInstructions + 1 ].
	].

	self instructionAdded: anInstruction
]

{ #category : #adding }
SLVMBasicBlock >> addPredecessor: aBasicBlock [
	predecessors add: aBasicBlock
]

{ #category : #adding }
SLVMBasicBlock >> addQuiet: anInstruction [ 
	self assert: anInstruction previousInstruction isNil.
	self assert: anInstruction nextInstruction isNil.
	lastInstruction ifNil: [
		anInstruction previousInstruction: nil.
		anInstruction nextInstruction: nil.
		firstInstruction := lastInstruction := anInstruction.
		numberOfInstructions := 1.
	]	ifNotNil: [
		lastInstruction nextInstruction: anInstruction.
		anInstruction previousInstruction: lastInstruction.
		lastInstruction := anInstruction.
		numberOfInstructions ifNotNil: [ numberOfInstructions := numberOfInstructions + 1 ].
	].

	anInstruction block: self
]

{ #category : #enumerating }
SLVMBasicBlock >> allocaInstructionsDo: aBlock [
	self instructionsDo: [:ins |
		ins isAlloca ifFalse: [ ^ self ].
		aBlock value: ins
	]
]

{ #category : #adding }
SLVMBasicBlock >> computeLastInstruction [
	| current |
	current := lastInstruction := firstInstruction.
	[ current isNotNil ] whileTrue: [
		lastInstruction := current.
		current := current nextInstruction
	].
	
]

{ #category : #adding }
SLVMBasicBlock >> computeSuccessors [
	successors := self lastInstruction successors.
	successors do: [ :suc | suc addPredecessor: self]

]

{ #category : #accessing }
SLVMBasicBlock >> countNumberOfInstructions [
	| current |
	numberOfInstructions := 0.
	current := self firstInstruction.
	[current isNotNil] whileTrue: [
		current := current nextInstruction.
		numberOfInstructions := numberOfInstructions + 1.
	]
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
	^ firstInstruction
]

{ #category : #printing }
SLVMBasicBlock >> fullPrintOn: aStream [
	aStream print: self; nextPut: $:.
	aStream space.
	self printArray: predecessors on: aStream.
	aStream space.
	self printArray: successors on: aStream.
	aStream cr.
	self instructionsDo: [ :ins | aStream tab. ins fullPrintOn: aStream. aStream cr ]
]

{ #category : #accessing }
SLVMBasicBlock >> function [
	^ function
]

{ #category : #accessing }
SLVMBasicBlock >> function: anObject [
	function := anObject
]

{ #category : #testing }
SLVMBasicBlock >> hasPhiInstructions [
	^ self isEmpty not and: [ self firstInstruction isPhi ]
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
	predecessors := Set new.
	successors := #().
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
	| currentInstruction nextInstruction |
	currentInstruction := self firstInstruction.
	[ currentInstruction isNotNil ] whileTrue: [ 
		nextInstruction := currentInstruction nextInstruction.
		aBlock value: currentInstruction.
		currentInstruction := nextInstruction
	]
]

{ #category : #testing }
SLVMBasicBlock >> isEmpty [
	^ firstInstruction isNil
]

{ #category : #testing }
SLVMBasicBlock >> isLastTerminator [
	^ self isEmpty not and: [ self lastInstruction isTerminator ]
]

{ #category : #accessing }
SLVMBasicBlock >> lastInstruction [
	^ lastInstruction
]

{ #category : #accessing }
SLVMBasicBlock >> livenessIndex [
	^ index
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
	numberOfInstructions ifNil: [ self countNumberOfInstructions ].
	^ numberOfInstructions
]

{ #category : #enumerating }
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
	(anInstruction previousInstruction isNil and: [ anInstruction nextInstruction isNil ]) ifTrue: [
		anInstruction block: nil.
		firstInstruction := lastInstruction := nil.
		numberOfInstructions := 0.
		^ self
	].

	anInstruction previousInstruction ifNil: [ 
		firstInstruction := anInstruction nextInstruction.
	] ifNotNil: [ 
		anInstruction previousInstruction nextInstruction: anInstruction nextInstruction
	].

	anInstruction nextInstruction ifNil: [
		lastInstruction := anInstruction previousInstruction.
	] ifNotNil: [ 
		anInstruction nextInstruction previousInstruction: anInstruction previousInstruction
	].

	anInstruction previousInstruction: nil.
	anInstruction nextInstruction: nil.
	anInstruction block: nil.
	numberOfInstructions ifNotNil: [numberOfInstructions := numberOfInstructions - 1].
]

{ #category : #adding }
SLVMBasicBlock >> removeChain: anInstructionChain [ 
	| current |
	current := anInstructionChain.
	[ current isNotNil ] whileTrue: [
		self assert: current block == self.
		current block: nil.
		current := current nextInstruction
	].
	
	anInstructionChain previousInstruction ifNil: [
		firstInstruction := lastInstruction := nil.
		numberOfInstructions := 0.
	] ifNotNil: [
		lastInstruction := anInstructionChain previousInstruction.
		lastInstruction nextInstruction: nil.
		anInstructionChain previousInstruction: nil.
		numberOfInstructions := nil.
	]
]

{ #category : #adding }
SLVMBasicBlock >> setChain: anInstructionChain [ 
	| current |
	numberOfInstructions := 0.
	firstInstruction := anInstructionChain.
	
	current := lastInstruction := anInstructionChain.
	[ current isNotNil ] whileTrue: [
		current block: self.
		lastInstruction := current.
		numberOfInstructions := numberOfInstructions + 1.
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
