Class {
	#name : #LLVMLandingPadInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'cleanup'
	],
	#category : #'LLVM-IR-Instructions'
}

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
	cleanup := false
]

{ #category : #printing }
LLVMLandingPadInst >> mnemonic [
	^ #landingpad
]

{ #category : #printing }
LLVMLandingPadInst >> printParametersOn: aStream [
	aStream space; print: type.
	cleanup ifTrue: [ aStream nextPutAll: ' cleanup' ].
]
