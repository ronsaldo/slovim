Class {
	#name : #LLVMStoreInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'value',
		'pointer',
		'volatile'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #initialization }
LLVMStoreInst >> initialize [
	super initialize.
	volatile := false.
]

{ #category : #printing }
LLVMStoreInst >> mnemonic [
	^ #store
]

{ #category : #accessing }
LLVMStoreInst >> pointer [
	^ pointer
]

{ #category : #accessing }
LLVMStoreInst >> pointer: anObject [
	pointer := anObject
]

{ #category : #printing }
LLVMStoreInst >> printParametersOn: aStream [
	volatile ifTrue: [ aStream nextPutAll: ' volatile' ].
	aStream space; print: value type; space; print: value.
	aStream nextPutAll: ', '; print: pointer type; space; print: pointer.

]

{ #category : #accessing }
LLVMStoreInst >> value [
	^ value
]

{ #category : #accessing }
LLVMStoreInst >> value: anObject [
	value := anObject
]

{ #category : #accessing }
LLVMStoreInst >> volatile [
	^ volatile
]

{ #category : #accessing }
LLVMStoreInst >> volatile: anObject [
	volatile := anObject
]
