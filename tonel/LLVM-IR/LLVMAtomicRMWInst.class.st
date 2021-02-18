Class {
	#name : #LLVMAtomicRMWInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'pointer',
		'operand',
		'operation',
		'ordering'
	],
	#classVars : [
		'OperationOpcodeMap'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'class initialization' }
LLVMAtomicRMWInst class >> initialize [
	OperationOpcodeMap := Dictionary newFromPairs: { 
		#xchg . LLVMAtomicRMWBinOpXchg.
		#add . LLVMAtomicRMWBinOpAdd.
		#sub . LLVMAtomicRMWBinOpSub.
		#and . LLVMAtomicRMWBinOpAnd.
		#nand . LLVMAtomicRMWBinOpNand.
		#or . LLVMAtomicRMWBinOpOr.
		#xor . LLVMAtomicRMWBinOpXor.
		#max . LLVMAtomicRMWBinOpMax.
		#min . LLVMAtomicRMWBinOpMin.
		#umax . LLVMAtomicRMWBinOpUMax.
		#umin . LLVMAtomicRMWBinOpUMin.
		#fadd . LLVMAtomicRMWBinOpFAdd.
		#fsub . LLVMAtomicRMWBinOpFSub.
	}
]

{ #category : #'as yet unclassified' }
LLVMAtomicRMWInst >> buildHandleWithBuilder: builder [
	handle := builder atomicRMW: (OperationOpcodeMap at: operation) pointer: pointer validHandle value: operand validHandle ordering: (AtomicOrderingMap at: ordering) singleThread: false
]

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
