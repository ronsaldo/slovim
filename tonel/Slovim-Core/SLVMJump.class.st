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
	mergeBlock predecessors ifEmpty: [
		unreachableSuccessors := { mergeBlock }.
		changed := true.
	].

	continueBlock predecessors ifEmpty: [
		unreachableSuccessors := { mergeBlock }.
		changed := true.
	].

	changed ifTrue: [ block computeSuccessors. ]
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
	aStream nextPutAll: 'jump '; nextPutAll:destination name
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
