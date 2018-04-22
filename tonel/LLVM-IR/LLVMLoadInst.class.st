Class {
	#name : #LLVMLoadInst,
	#superclass : #LLVMUnaryInstruction,
	#instVars : [
		'pointer',
		'volatile'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMLoadInst >> initialize [
	super initialize.
	volatile := false.
]

{ #category : #printing }
LLVMLoadInst >> mnemonic [
	^ #load
]

{ #category : #accessing }
LLVMLoadInst >> pointer [
	^ pointer
]

{ #category : #accessing }
LLVMLoadInst >> pointer: anObject [
	pointer := anObject
]

{ #category : #printing }
LLVMLoadInst >> printParametersOn: aStream [
	volatile ifTrue: [ aStream nextPutAll: ' volatile' ].
	aStream space; print: type; nextPutAll: ', '; print: pointer type; space; print: pointer.

]

{ #category : #accessing }
LLVMLoadInst >> volatile [
	^ volatile
]

{ #category : #accessing }
LLVMLoadInst >> volatile: anObject [
	volatile := anObject
]
