Class {
	#name : #SLVMBranch,
	#superclass : #SLVMInstruction,
	#instVars : [
		'trueBlock',
		'falseBlock',
		'mergeBlock',
		'continueBlock',
		'unreachableSuccessors'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMBranch class >> condition: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock [
	^ self new condition: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock
]

{ #category : #visitor }
SLVMBranch >> accept: aVisitor [
	^ aVisitor visitBranch: self
]

{ #category : #accessing }
SLVMBranch >> addUnreachableSuccessors [
	| changed |
	changed := false.
	unreachableSuccessors := #().
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
SLVMBranch >> applySubstitutions: substitutionDictionary [
	super applySubstitutions: substitutionDictionary.
	falseBlock := substitutionDictionary at: falseBlock.
	trueBlock := substitutionDictionary at: trueBlock.
	mergeBlock ifNotNil: [ mergeBlock := substitutionDictionary at: mergeBlock ].
	continueBlock ifNotNil: [ continueBlock := substitutionDictionary at: continueBlock ].
]

{ #category : #accessing }
SLVMBranch >> condition [
	^ parameters first
]

{ #category : #construction }
SLVMBranch >> condition: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock [
	self parameters: { condition }.
	trueBlock := ifTrueBlock.
	falseBlock := ifFalseBlock.
]

{ #category : #accessing }
SLVMBranch >> continueBlock [
	^ continueBlock
]

{ #category : #accessing }
SLVMBranch >> continueBlock: anObject [
	continueBlock := anObject
]

{ #category : #accessing }
SLVMBranch >> falseBlock [
	^ falseBlock
]

{ #category : #accessing }
SLVMBranch >> falseBlock: anObject [
	falseBlock := anObject
]

{ #category : #printing }
SLVMBranch >> fullPrintOn: aStream [
	aStream nextPutAll: 'branch '; print: self condition;
		space; print: trueBlock;
		space; print: falseBlock
]

{ #category : #testing }
SLVMBranch >> hasOutputs [
	^ false
]

{ #category : #initialization }
SLVMBranch >> initialize [
	super initialize.
	unreachableSuccessors := #()
]

{ #category : #testing }
SLVMBranch >> isBranch [
	^ true
]

{ #category : #testing }
SLVMBranch >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMBranch >> mergeBlock [
	^ mergeBlock
]

{ #category : #accessing }
SLVMBranch >> mergeBlock: anObject [
	mergeBlock := anObject
]

{ #category : #printing }
SLVMBranch >> mnemonic [
	^ #branch
]

{ #category : #'as yet unclassified' }
SLVMBranch >> postCopy [
	super postCopy.
	unreachableSuccessors := #()
]

{ #category : #accessing }
SLVMBranch >> successors [
	^ { trueBlock . falseBlock } , unreachableSuccessors
]

{ #category : #accessing }
SLVMBranch >> trueBlock [
	^ trueBlock
]

{ #category : #accessing }
SLVMBranch >> trueBlock: anObject [
	trueBlock := anObject
]

{ #category : #accessing }
SLVMBranch >> type [
	^ SLVMType voidType
]

{ #category : #testing }
SLVMBranch >> validateInBlock: aBasicBlock [
	super validateInBlock: aBasicBlock.
	self assert: (block function basicBlocks includes: trueBlock).
	self assert: (block function basicBlocks includes: falseBlock).
	self assert: (mergeBlock isNil or: [block function basicBlocks includes: mergeBlock]).
	self assert: (continueBlock isNil or: [block function basicBlocks includes: continueBlock]).
	self assert: self block successors = self successors.
]
