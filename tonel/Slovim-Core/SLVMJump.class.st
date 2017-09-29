Class {
	#name : #SLVMJump,
	#superclass : #SLVMInstruction,
	#instVars : [
		'destination',
		'mergeBlock',
		'continueBlock',
		'unreachableSuccessors'
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
SLVMJump >> addUnreachableSuccessors [
	| changed |
	changed := false.
	(mergeBlock isNotNil and: [ mergeBlock predecessors isEmpty ]) ifTrue: [
		unreachableSuccessors := { mergeBlock }.
		changed := true.
	].

	(continueBlock isNotNil and: [ continueBlock predecessors isEmpty]) ifTrue: [
		unreachableSuccessors := unreachableSuccessors , { continueBlock }.
		changed := true.
	].

	changed ifTrue: [ block computeSuccessors. ]
]

{ #category : #'as yet unclassified' }
SLVMJump >> applySubstitutions: substitutionDictionary [
	destination := substitutionDictionary at: destination.
	mergeBlock ifNotNil: [ mergeBlock := substitutionDictionary at: mergeBlock ].
	continueBlock ifNotNil: [ continueBlock := substitutionDictionary at: continueBlock ].
]

{ #category : #accessing }
SLVMJump >> continueBlock [
	^ continueBlock
]

{ #category : #accessing }
SLVMJump >> continueBlock: anObject [
	continueBlock := anObject
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

{ #category : #'as yet unclassified' }
SLVMJump >> initialize [
	super initialize.
	unreachableSuccessors := #()
]

{ #category : #testing }
SLVMJump >> isJump [
	^ true
]

{ #category : #testing }
SLVMJump >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMJump >> mergeBlock [
	^ mergeBlock
]

{ #category : #accessing }
SLVMJump >> mergeBlock: anObject [
	mergeBlock := anObject
]

{ #category : #printing }
SLVMJump >> mnemonic [
	^ #jump
]

{ #category : #'as yet unclassified' }
SLVMJump >> postCopy [
	super postCopy.
	unreachableSuccessors := #()
]

{ #category : #printing }
SLVMJump >> printOn: aStream [
	aStream nextPutAll: self mnemonic; print: destination
]

{ #category : #accessing }
SLVMJump >> successors [
	^ { destination } , unreachableSuccessors
]

{ #category : #accessing }
SLVMJump >> type [
	^ SLVMType voidType
]

{ #category : #testing }
SLVMJump >> validateInBlock: aBasicBlock [
	super validateInBlock: aBasicBlock.
	self assert: (block function basicBlocks includes: destination).
	self assert: (mergeBlock isNil or: [block function basicBlocks includes: mergeBlock]).
	self assert: (continueBlock isNil or: [block function basicBlocks includes: continueBlock]).
	self assert: self block successors = self successors
]
