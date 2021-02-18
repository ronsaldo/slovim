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

{ #category : #'as yet unclassified' }
LLVMPHINode >> buildHandleWithBuilder: builder [
	handle := builder phi: type validHandle name: name llvmNameForHandle
]

{ #category : #'as yet unclassified' }
LLVMPHINode >> fixupInstructionHandle [
	| incomingValueHandles incomingBlocksHandles |
	incomingValueHandles := LLVMValueRefArray withAll: (incomingValues collect: [ :each | each first ]).
	incomingBlocksHandles := LLVMBlockRefArray withAll: (incomingValues collect: [ :each | each second validEndingBlock ]).
	handle addIncomingValues: incomingValueHandles getHandle blocks: incomingBlocksHandles getHandle count: incomingValues size
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
				nextPutAll: ', '; print: incoming second validEndingBlock; nextPutAll: ' ]'
	].
]
