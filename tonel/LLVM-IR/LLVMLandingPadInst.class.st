Class {
	#name : #LLVMLandingPadInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'cleanup',
		'catchedExceptions'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMLandingPadInst >> catchedExceptions [
	^ catchedExceptions
]

{ #category : #accessing }
LLVMLandingPadInst >> catchedExceptions: anObject [
	catchedExceptions := anObject
]

{ #category : #accessing }
LLVMLandingPadInst >> cleanup [
	^ cleanup
]

{ #category : #accessing }
LLVMLandingPadInst >> cleanup: anObject [
	cleanup := anObject
]

{ #category : #initialization }
LLVMLandingPadInst >> initialize [
	super initialize.
	cleanup := false.
	catchedExceptions := #().
]

{ #category : #printing }
LLVMLandingPadInst >> mnemonic [
	^ #landingpad
]

{ #category : #printing }
LLVMLandingPadInst >> printParametersOn: aStream [
	aStream space; print: type.
	cleanup ifTrue: [ aStream nextPutAll: ' cleanup' ].
	catchedExceptions do: [ :each | aStream nextPutAll: ' catch '; print: each type; space; print: each ]
]
