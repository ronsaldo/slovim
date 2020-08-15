"
I represent a control flow if style branch,
"
Class {
	#name : #SLVMBranch,
	#superclass : #SLVMInstruction,
	#instVars : [
		'trueBlock',
		'falseBlock'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMBranch class >> condition: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock [
	^ self new condition: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock
]

{ #category : #printing }
SLVMBranch class >> mnemonic [
	^ #branch
]

{ #category : #visitor }
SLVMBranch >> accept: aVisitor [
	^ aVisitor visitBranch: self
]

{ #category : #'as yet unclassified' }
SLVMBranch >> applySubstitutions: substitutionDictionary [
	super applySubstitutions: substitutionDictionary.
	trueBlock := substitutionDictionary at: trueBlock.
	falseBlock := substitutionDictionary at: falseBlock.
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

{ #category : #printing }
SLVMBranch >> extraParametersSExpression [
	^ {trueBlock asSExpression . falseBlock asSExpression}
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
	aStream putKeyword: #branch; space; print: self condition;
		space; print: trueBlock;
		space; print: falseBlock
]

{ #category : #testing }
SLVMBranch >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMBranch >> isBranch [
	^ true
]

{ #category : #testing }
SLVMBranch >> isTerminator [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMBranch >> postCopy [
	super postCopy.
]

{ #category : #accessing }
SLVMBranch >> successors [
	^ { trueBlock . falseBlock }
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
	self assert: (self block successors includesAll: self successors).
]
