Class {
	#name : #LLVMPHINode,
	#superclass : #LLVMInstruction,
	#instVars : [
		'incomingValues'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #adding }
LLVMPHINode >> addValue: value incomingFrom: incomingBlock [
	^ incomingValues add: { value . incomingBlock }
]

{ #category : #initialization }
LLVMPHINode >> initialize [
	super initialize.
	incomingValues := OrderedCollection new.
	
]

{ #category : #printing }
LLVMPHINode >> mnemonic [
	^ #phi
]

{ #category : #printing }
LLVMPHINode >> printParametersOn: aStream [
	aStream space; print: type; space.
	incomingValues doWithIndex: [ :incoming :index |
		index >1 ifTrue: [
			aStream nextPutAll: ', '
		].
	
		aStream nextPutAll: '[ '; print: incoming first;
				nextPutAll: ', '; print: incoming second; nextPutAll: ' ]'
	].
]
