Class {
	#name : #LLVMSelectInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'condition',
		'trueValue',
		'falseValue'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMSelectInst >> condition [
	^ condition
]

{ #category : #accessing }
LLVMSelectInst >> condition: anObject [
	condition := anObject
]

{ #category : #accessing }
LLVMSelectInst >> falseValue [
	^ falseValue
]

{ #category : #accessing }
LLVMSelectInst >> falseValue: anObject [
	falseValue := anObject
]

{ #category : #printing }
LLVMSelectInst >> mnemonic [
	^ #select
]

{ #category : #printing }
LLVMSelectInst >> printParametersOn: aStream [
	aStream space; print: condition type; space; print: condition;
		nextPutAll: ', '; print: trueValue type; space; print: trueValue;
		nextPutAll: ', '; print: falseValue type; space; print: falseValue
]

{ #category : #accessing }
LLVMSelectInst >> trueValue [
	^ trueValue
]

{ #category : #accessing }
LLVMSelectInst >> trueValue: anObject [
	trueValue := anObject
]
