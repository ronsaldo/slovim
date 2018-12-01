Class {
	#name : #LLVMAtomicRMWInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'pointer',
		'operand',
		'operation',
		'ordering'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMAtomicRMWInst >> initialize [
	super initialize.
	ordering := #monotonic.
]

{ #category : #printing }
LLVMAtomicRMWInst >> mnemonic [
	^ #atomicrmw
]

{ #category : #accessing }
LLVMAtomicRMWInst >> operand [
	^ operand
]

{ #category : #accessing }
LLVMAtomicRMWInst >> operand: anObject [
	operand := anObject
]

{ #category : #accessing }
LLVMAtomicRMWInst >> operation [
	^ operation
]

{ #category : #accessing }
LLVMAtomicRMWInst >> operation: anObject [
	operation := anObject
]

{ #category : #accessing }
LLVMAtomicRMWInst >> ordering [
	^ ordering
]

{ #category : #accessing }
LLVMAtomicRMWInst >> ordering: anObject [
	ordering := anObject
]

{ #category : #accessing }
LLVMAtomicRMWInst >> pointer [
	^ pointer
]

{ #category : #accessing }
LLVMAtomicRMWInst >> pointer: anObject [
	pointer := anObject
]

{ #category : #accessing }
LLVMAtomicRMWInst >> printParametersOn: aStream [
	aStream
		space; nextPutAll: operation;
		space; print: pointer type; space; print: pointer;
		nextPutAll: ', '; print: operand type; space; print: operand;
		space; nextPutAll: ordering
]
