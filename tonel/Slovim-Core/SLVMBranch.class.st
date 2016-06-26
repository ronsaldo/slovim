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
	mergeBlock predecessors ifEmpty: [
		unreachableSuccessors := { mergeBlock }.
		changed := true.
	].

	(continueBlock isNil not and: [ continueBlock isEmpty not]) ifTrue: [
		unreachableSuccessors := { mergeBlock }.
		changed := true.
	].

	changed ifTrue: [ block computeSuccessors. ]
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
	^ false
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
