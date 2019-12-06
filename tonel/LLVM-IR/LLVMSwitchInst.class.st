Class {
	#name : #LLVMSwitchInst,
	#superclass : #LLVMTerminatorInst,
	#instVars : [
		'condition',
		'defaultDest',
		'caseValues',
		'caseDests'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMSwitchInst >> caseDests [
	^ caseDests
]

{ #category : #accessing }
LLVMSwitchInst >> caseDests: anObject [
	caseDests := anObject
]

{ #category : #accessing }
LLVMSwitchInst >> caseValues [
	^ caseValues
]

{ #category : #accessing }
LLVMSwitchInst >> caseValues: anObject [
	caseValues := anObject
]

{ #category : #accessing }
LLVMSwitchInst >> condition [
	^ condition
]

{ #category : #accessing }
LLVMSwitchInst >> condition: anObject [
	condition := anObject
]

{ #category : #accessing }
LLVMSwitchInst >> defaultDest [
	^ defaultDest
]

{ #category : #accessing }
LLVMSwitchInst >> defaultDest: anObject [
	defaultDest := anObject
]

{ #category : #printing }
LLVMSwitchInst >> mnemonic [
	^ #switch
]

{ #category : #printing }
LLVMSwitchInst >> printParametersOn: aStream [
	aStream space; print: condition type; space; print: condition;
		nextPutAll: ', label '; print: defaultDest;
		nextPutAll: ' ['.
	1 to: caseValues size do: [ :index |
		| caseValue caseDest |
		caseValue := caseValues at: index.
		caseDest := caseDests at: index.
		aStream space; print: caseValue type; space; print: caseValue;
			nextPutAll: ', label '; print: caseDest
	].
	aStream nextPutAll: ' ]'

]
