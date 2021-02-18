Class {
	#name : #LLVMFCmpInst,
	#superclass : #LLVMCmpInst,
	#classVars : [
		'BinaryOperationToOpcodeMap'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'class initialization' }
LLVMFCmpInst class >> initialize [
	BinaryOperationToOpcodeMap := Dictionary newFromPairs: { 
		#oeq . LLVMRealOEQ.
		#one . LLVMRealONE.
		#ogt . LLVMRealOGT.
		#oge . LLVMRealOGE.
		#olt . LLVMRealOLT.
		#ole . LLVMRealOLE.

		#ueq . LLVMRealUEQ.
		#une . LLVMRealUNE.
		#ugt . LLVMRealUGT.
		#uge . LLVMRealUGE.
		#ult . LLVMRealULT.
		#ule . LLVMRealULE.
	}
]

{ #category : #'as yet unclassified' }
LLVMFCmpInst >> buildHandleWithBuilder: builder [
	handle := builder fcmp: (BinaryOperationToOpcodeMap at: operation) left: left validHandle right: right validHandle name: name llvmNameForHandle
]

{ #category : #printing }
LLVMFCmpInst >> mnemonic [
	^ #fcmp
]
