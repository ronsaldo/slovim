Class {
	#name : #LLVMAllocaInst,
	#superclass : #LLVMUnaryInstruction,
	#instVars : [
		'valueType',
		'alignment'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMAllocaInst >> alignment [
	^ alignment
]

{ #category : #accessing }
LLVMAllocaInst >> alignment: anObject [
	alignment := anObject
]

{ #category : #'as yet unclassified' }
LLVMAllocaInst >> buildHandleWithBuilder: builder [
	handle := builder alloca: valueType validHandle name: name llvmNameForHandle.
	alignment ifNotNil: [
		handle setAlignment: alignment
	]
]

{ #category : #testing }
LLVMAllocaInst >> isAlloca [
	^ true
]

{ #category : #printing }
LLVMAllocaInst >> mnemonic [
	^ #alloca
]

{ #category : #printing }
LLVMAllocaInst >> printParametersOn: aStream [
	aStream space; print: valueType.
	alignment ifNotNil: [ aStream nextPutAll: ', align '; print: alignment ]
]

{ #category : #accessing }
LLVMAllocaInst >> valueType [
	^ valueType
]

{ #category : #accessing }
LLVMAllocaInst >> valueType: anObject [
	valueType := anObject
]
