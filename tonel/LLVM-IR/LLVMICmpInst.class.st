Class {
	#name : #LLVMICmpInst,
	#superclass : #LLVMCmpInst,
	#classVars : [
		'BinaryOperationToOpcodeMap'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'class initialization' }
LLVMICmpInst class >> initialize [
	BinaryOperationToOpcodeMap := Dictionary newFromPairs: { 
		#eq . LLVMIntEQ.
		#ne . LLVMIntNE.
		#ugt . LLVMIntUGT.
		#uge . LLVMIntUGE.
		#ult . LLVMIntULT.
		#ule . LLVMIntULE.
		#sgt . LLVMIntSGT.
		#sge . LLVMIntSGE.
		#slt . LLVMIntSLT.
		#sle . LLVMIntSLE.
	}
]

{ #category : #'as yet unclassified' }
LLVMICmpInst >> buildHandleWithBuilder: builder [
	handle := builder icmp: (BinaryOperationToOpcodeMap at: operation) left: left validHandle right: right validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMICmpInst >> mnemonic [
	^ #icmp
]
