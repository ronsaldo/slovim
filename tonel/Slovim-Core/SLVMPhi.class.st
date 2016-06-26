Class {
	#name : #SLVMPhi,
	#superclass : #SLVMInstruction,
	#instVars : [
		'incomingBlocks'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMPhi >> accept: aVisitor [
	^ aVisitor visitPhi: self
]

{ #category : #adding }
SLVMPhi >> addValue: value from: incomingBlock [
	value addInstructionReference: self.
	parameters add: value.
	incomingBlocks add: incomingBlock.
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

{ #category : #printing }
SLVMPhi >> mnemonic [
	^ 'phi'
]

{ #category : #adding }
SLVMPhi >> type [
	^ self parameters first type
]

{ #category : #adding }
SLVMPhi >> valuesAndParentsDo: aBlock [
	1 to: parameters size do: [ :i |
		aBlock value: (parameters at: i) value: (incomingBlocks at: i)
	]
]
