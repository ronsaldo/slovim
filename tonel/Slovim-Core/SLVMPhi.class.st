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

{ #category : #adding }
SLVMPhi >> addValue: value from: incomingBlock [
	self assert: value type = type.
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

{ #category : #testing }
SLVMPhi >> isPureInstruction [
	^ true
]

{ #category : #printing }
SLVMPhi >> mnemonic [
	^ 'phi'
]

{ #category : #adding }
SLVMPhi >> replaceParent: oldParent with: newParent [
	incomingBlocks doWithIndex: [ :incoming :index |
		incoming = oldParent ifTrue: [ incomingBlocks at: index put: newParent ]
	]
]

{ #category : #accessing }
SLVMPhi >> type [
	^ type
]

{ #category : #accessing }
SLVMPhi >> type: anObject [
	type := anObject
]

{ #category : #adding }
SLVMPhi >> valueFromIncomingBlock: aBlock [
	^ parameters at: (incomingBlocks indexOf: aBlock ifAbsent: [ ^ nil ])
]

{ #category : #adding }
SLVMPhi >> valuesAndParentsDo: aBlock [
	1 to: parameters size do: [ :i |
		aBlock value: (parameters at: i) value: (incomingBlocks at: i)
	]
]
