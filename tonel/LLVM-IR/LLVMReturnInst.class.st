Class {
	#name : #LLVMReturnInst,
	#superclass : #LLVMTerminatorInst,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMReturnInst >> buildHandleWithBuilder: builder [
	value ifNil: [
		handle := builder retVoid
	] ifNotNil: [ 
		handle := builder ret: value validHandle
	].
]

{ #category : #printing }
LLVMReturnInst >> mnemonic [
	^ #ret
]

{ #category : #printing }
LLVMReturnInst >> printParametersOn: aStream [
	aStream space.
	value ifNotNil: [
		aStream print: value type; space; print: value
	] ifNil: [ 
		aStream nextPutAll: 'void'
	]
	
]

{ #category : #accessing }
LLVMReturnInst >> value [
	^ value
]

{ #category : #accessing }
LLVMReturnInst >> value: anObject [
	value := anObject
]
