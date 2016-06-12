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
	parameters add: value.
	incomingBlocks add: incomingBlock.
]

{ #category : #initialization }
SLVMPhi >> initialize [
	parameters := OrderedCollection new.
	incomingBlocks := OrderedCollection new.
]

{ #category : #printing }
SLVMPhi >> mnemonic [
	^ 'phi'
]
