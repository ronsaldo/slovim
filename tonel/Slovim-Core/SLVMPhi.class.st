Class {
	#name : #SLVMPhi,
	#superclass : #SLVMInstruction,
	#instVars : [
		'incomingBlocks',
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMPhi class >> type: aType [
	^ self new type: aType
]

{ #category : #visitor }
SLVMPhi >> accept: aVisitor [
	^ aVisitor visitPhi: self
]

{ #category : #optimizations }
SLVMPhi >> addValue: value from: incomingBlock [
	self assert: value type = type.
	value addInstructionReference: self.
	parameters add: value.
	incomingBlocks add: incomingBlock.
]

{ #category : #'as yet unclassified' }
SLVMPhi >> applySubstitutions: substitutionDictionary [
	super applySubstitutions: substitutionDictionary.
	incomingBlocks := incomingBlocks collect: [ :bl | substitutionDictionary at: bl ]
]

{ #category : #'basic optimizations' }
SLVMPhi >> foldConstant [
	self assert: incomingBlocks size = block predecessors size.
	"block predecessors size = 1 ifTrue: [ ^ parameters first ]."
	^ self
]

{ #category : #optimizations }
SLVMPhi >> incomingBlockRemoved: oldBlock [
	| newParameters newIncomingBlocks param incomingBlock |
	newParameters := OrderedCollection new.
	newIncomingBlocks := OrderedCollection new.
	1 to: parameters size do: [ :i |
		param := parameters at: i.
		incomingBlock := incomingBlocks at: i.
		incomingBlock == oldBlock ifFalse: [
			newParameters add: param.
			newIncomingBlocks add: incomingBlock.
		]
	].

	parameters := newParameters.
	incomingBlocks := newIncomingBlocks.
]

{ #category : #accessing }
SLVMPhi >> incomingBlocks [
	^ incomingBlocks
]

{ #category : #initialization }
SLVMPhi >> initialize [
	super initialize.
	parameters := OrderedCollection new.
	incomingBlocks := OrderedCollection new.
]

{ #category : #testing }
SLVMPhi >> isPhi [
	^ true
]

{ #category : #testing }
SLVMPhi >> isPureInstruction [
	^ true
]

{ #category : #printing }
SLVMPhi >> mnemonic [
	^ #phi
]

{ #category : #optimizations }
SLVMPhi >> replaceParent: oldParent with: newParent [
	incomingBlocks doWithIndex: [ :incoming :index |
		incoming = oldParent ifTrue: [ incomingBlocks at: index put: newParent ]
	]
]

{ #category : #accessing }
SLVMPhi >> signature [
	^ super signature , { incomingBlocks }
]

{ #category : #accessing }
SLVMPhi >> type [
	^ type
]

{ #category : #accessing }
SLVMPhi >> type: anObject [
	type := anObject
]

{ #category : #optimizations }
SLVMPhi >> valueFromIncomingBlock: aBlock [
	^ parameters at: (incomingBlocks indexOf: aBlock ifAbsent: [ ^ nil ])
]

{ #category : #optimizations }
SLVMPhi >> valuesAndParentsDo: aBlock [
	1 to: parameters size do: [ :i |
		aBlock value: (parameters at: i) value: (incomingBlocks at: i)
	]
]
