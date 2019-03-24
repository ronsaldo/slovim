Class {
	#name : #SLVMJump,
	#superclass : #SLVMInstruction,
	#instVars : [
		'destination'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMJump class >> destination: aBasicBlock [
	^ self new destination: aBasicBlock
]

{ #category : #visitor }
SLVMJump >> accept: aVisitor [
	^ aVisitor visitJump: self
]

{ #category : #'as yet unclassified' }
SLVMJump >> applySubstitutions: substitutionDictionary [
	super applySubstitutions: substitutionDictionary.
	destination := substitutionDictionary at: destination
]

{ #category : #accessing }
SLVMJump >> destination [
	^ destination
]

{ #category : #accessing }
SLVMJump >> destination: anObject [
	destination := anObject
]

{ #category : #printing }
SLVMJump >> fullPrintOn: aStream [
	aStream putKeyword: #jump; space; print: destination
]

{ #category : #testing }
SLVMJump >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMJump >> isJump [
	^ true
]

{ #category : #testing }
SLVMJump >> isTerminator [
	^ true
]

{ #category : #printing }
SLVMJump >> mnemonic [
	^ #jump
]

{ #category : #printing }
SLVMJump >> printOn: aStream [
	aStream nextPutAll: self mnemonic; space; print: destination
]

{ #category : #accessing }
SLVMJump >> successors [
	^ { destination }
]

{ #category : #accessing }
SLVMJump >> type [
	^ SLVMType voidType
]

{ #category : #testing }
SLVMJump >> validateInBlock: aBasicBlock [
	super validateInBlock: aBasicBlock.
	self assert: (block function basicBlocks includes: destination).
	self assert: self block successors = self successors
]
