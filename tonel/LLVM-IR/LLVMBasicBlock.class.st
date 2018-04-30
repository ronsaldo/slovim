Class {
	#name : #LLVMBasicBlock,
	#superclass : #LLVMValue,
	#instVars : [
		'parent',
		'instructions'
	],
	#category : #'LLVM-IR'
}

{ #category : #'as yet unclassified' }
LLVMBasicBlock class >> for: context name: theName [
	^ self new initializeWithContext: context name: theName parent: nil insertBefore: nil
]

{ #category : #'as yet unclassified' }
LLVMBasicBlock class >> for: context name: theName parent: theParentFunction [
	^ self new initializeWithContext: context name: theName parent: theParentFunction insertBefore: nil
]

{ #category : #'as yet unclassified' }
LLVMBasicBlock class >> for: context name: theName parent: theParentFunction insertBefore: previousBasicBlock [
	^ self new initializeWithContext: context name: theName parent: theParentFunction insertBefore: previousBasicBlock
]

{ #category : #adding }
LLVMBasicBlock >> addNext: anInstruction [
	anInstruction parent: self.
	instructions add: anInstruction
]

{ #category : #printing }
LLVMBasicBlock >> fullPrintOn: aStream [
	aStream nextPutAll: name; nextPut: $:; lf.
	instructions do: [ :instruction |
		aStream tab.
		instruction fullPrintOn: aStream.
		aStream lf
	]
]

{ #category : #initialization }
LLVMBasicBlock >> initialize [
	super initialize.
	instructions := OrderedCollection new.

]

{ #category : #initialization }
LLVMBasicBlock >> initializeWithContext: context name: theName parent: theParentFunction insertBefore: previousBasicBlock [
	type := context labelTy.
	self name: theName.
	theParentFunction ifNotNil: [ 
		theParentFunction addBasicBlock: self before: previousBasicBlock
	].

]

{ #category : #accessing }
LLVMBasicBlock >> instructions [
	^ instructions
]

{ #category : #enumerating }
LLVMBasicBlock >> instructionsDo: aBlock [
	^ instructions do: aBlock
]

{ #category : #'as yet unclassified' }
LLVMBasicBlock >> instructionsReplaceWith: aBlock [
	| newInstructions replacement |
	newInstructions := OrderedCollection new.
	instructions do: [ :instruction |
		replacement := aBlock value: instruction.
		replacement isCollection ifTrue: [
			newInstructions addAll: replacement
		] ifFalse: [
			newInstructions add: replacement
		]
	].

	instructions := newInstructions
]

{ #category : #accessing }
LLVMBasicBlock >> parent [
	^ parent
]

{ #category : #accessing }
LLVMBasicBlock >> parent: anObject [
	parent := anObject
]