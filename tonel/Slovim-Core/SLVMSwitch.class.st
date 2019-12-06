Class {
	#name : #SLVMSwitch,
	#superclass : #SLVMInstruction,
	#instVars : [
		'caseBlocks',
		'defaultBlock'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMSwitch class >> matchedValue: matchedValue caseConstants: casesConstants caseBlocks: casesBlocks defaultBlock: defaultBlock [
	^ self new matchedValue: matchedValue caseConstants: casesConstants caseBlocks: casesBlocks defaultBlock: defaultBlock
]

{ #category : #visitor }
SLVMSwitch >> accept: aVisitor [
	^ aVisitor visitSwitch: self
]

{ #category : #'as yet unclassified' }
SLVMSwitch >> applySubstitutions: substitutionDictionary [
	super applySubstitutions: substitutionDictionary.
	caseBlocks := caseBlocks collect: [ :b | substitutionDictionary at: b ].
	defaultBlock := substitutionDictionary at: defaultBlock.
]

{ #category : #accessing }
SLVMSwitch >> caseBlocks [
	^ caseBlocks
]

{ #category : #'as yet unclassified' }
SLVMSwitch >> caseConstants [
	^ parameters allButFirst
]

{ #category : #accessing }
SLVMSwitch >> defaultBlock [
	^ defaultBlock
]

{ #category : #printing }
SLVMSwitch >> fullPrintOn: aStream [
	super fullPrintOn: aStream.
	caseBlocks do: [ :b | aStream space; print: b ].
	aStream space; print: defaultBlock
]

{ #category : #testing }
SLVMSwitch >> isSwitch [
	^ true
]

{ #category : #testing }
SLVMSwitch >> isTerminator [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMSwitch >> matchedValue [
	^ parameters first
]

{ #category : #'as yet unclassified' }
SLVMSwitch >> matchedValue: matchedValue caseConstants: casesConstants caseBlocks: theCaseBlocks defaultBlock: theDefaultBlock [
	self parameters: { matchedValue } , casesConstants.
	caseBlocks := theCaseBlocks asArray.
	defaultBlock := theDefaultBlock
]

{ #category : #printing }
SLVMSwitch >> mnemonic [
	^ #switch
]

{ #category : #accessing }
SLVMSwitch >> successors [
	^ caseBlocks , { defaultBlock }
]

{ #category : #accessing }
SLVMSwitch >> type [
	^ SLVMType voidType
]

{ #category : #testing }
SLVMSwitch >> validateInBlock: aBasicBlock [
	super validateInBlock: aBasicBlock.
	self assert: (block function basicBlocks includesAll: caseBlocks).
	self assert: (block function basicBlocks includes: defaultBlock).
	self assert: self block successors = self successors.
]
