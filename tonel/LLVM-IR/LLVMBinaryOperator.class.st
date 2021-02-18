Class {
	#name : #LLVMBinaryOperator,
	#superclass : #LLVMInstruction,
	#instVars : [
		'operation',
		'left',
		'right'
	],
	#classVars : [
		'BinaryOperationToOpcodeMap'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'class initialization' }
LLVMBinaryOperator class >> initialize [
	BinaryOperationToOpcodeMap := Dictionary newFromPairs: { 
		#add . LLVMAdd.
		#fadd . LLVMFAdd.
		#sub . LLVMSub.
		#fsub . LLVMFSub.
		#mul . LLVMMul.
		#fmul . LLVMFMul.
		#sdiv . LLVMSDiv.
		#udiv . LLVMUDiv.
		#fdiv . LLVMFDiv.
		#srem . LLVMSRem.
		#urem . LLVMURem.
		#frem . LLVMFRem.

		#and . LLVMAnd.
		#or . LLVMOr.
		#xor . LLVMXor.

		#shl . LLVMShl.
		#lshr . LLVMLShr.
		#ashr . LLVMAShr
	}.
]

{ #category : #'as yet unclassified' }
LLVMBinaryOperator >> buildHandleWithBuilder: builder [
	handle := builder binOp: (BinaryOperationToOpcodeMap at: operation) left: left validHandle right: right validHandle name: name llvmNameForHandle
]

{ #category : #accessing }
LLVMBinaryOperator >> left [
	^ left
]

{ #category : #accessing }
LLVMBinaryOperator >> left: anObject [
	left := anObject
]

{ #category : #printing }
LLVMBinaryOperator >> mnemonic [
	^ operation
]

{ #category : #accessing }
LLVMBinaryOperator >> operation [
	^ operation
]

{ #category : #accessing }
LLVMBinaryOperator >> operation: anObject [
	operation := anObject
]

{ #category : #printing }
LLVMBinaryOperator >> printParametersOn: aStream [
	aStream space; print: type; space; print: left; nextPutAll: ', '; print: right
]

{ #category : #accessing }
LLVMBinaryOperator >> right [
	^ right
]

{ #category : #accessing }
LLVMBinaryOperator >> right: anObject [
	right := anObject
]
