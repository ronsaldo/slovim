Class {
	#name : #LLVMInstructionProxy,
	#superclass : #LLVMValueProxy,
	#instVars : [
		'sourceValue',
		'parent'
	],
	#category : #'LLVM-IR'
}

{ #category : #accessing }
LLVMInstructionProxy >> parent [
	^ parent
]

{ #category : #accessing }
LLVMInstructionProxy >> parent: anObject [
	parent := anObject
]

{ #category : #accessing }
LLVMInstructionProxy >> sourceValue [
	^ sourceValue
]

{ #category : #accessing }
LLVMInstructionProxy >> sourceValue: anObject [
	sourceValue := anObject
]
