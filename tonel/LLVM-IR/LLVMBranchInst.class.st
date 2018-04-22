Class {
	#name : #LLVMBranchInst,
	#superclass : #LLVMTerminatorInst,
	#instVars : [
		'condition',
		'trueDestination',
		'falseDestination'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMBranchInst >> condition [
	^ condition
]

{ #category : #accessing }
LLVMBranchInst >> condition: anObject [
	condition := anObject
]

{ #category : #accessing }
LLVMBranchInst >> falseDestination [
	^ falseDestination
]

{ #category : #accessing }
LLVMBranchInst >> falseDestination: anObject [
	falseDestination := anObject
]

{ #category : #printing }
LLVMBranchInst >> mnemonic [
	^ #br
]

{ #category : #printing }
LLVMBranchInst >> printParametersOn: aStream [
	condition ifNil: [ 
		aStream nextPutAll: ' label '; print: trueDestination.
		^ self
	].

	aStream nextPutAll: ' i1 '; print: condition.
	aStream nextPutAll: ', label '; print: trueDestination.
	aStream nextPutAll: ', label '; print: falseDestination.

]

{ #category : #accessing }
LLVMBranchInst >> trueDestination [
	^ trueDestination
]

{ #category : #accessing }
LLVMBranchInst >> trueDestination: anObject [
	trueDestination := anObject
]
