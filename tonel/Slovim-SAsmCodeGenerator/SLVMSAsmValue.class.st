Class {
	#name : #SLVMSAsmValue,
	#superclass : #Object,
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #accessing }
SLVMSAsmValue class >> operand: anOperand [
	^ self operands: { anOperand asSAsmInstructionOperand }
]

{ #category : #accessing }
SLVMSAsmValue class >> operands: anArrayOfRegisters [
	^ SLVMSAsmOperandSet new registers: anArrayOfRegisters
]

{ #category : #accessing }
SLVMSAsmValue class >> registers: anArrayOfRegisters [
	^ SLVMSAsmOperandSet new registers: anArrayOfRegisters
]

{ #category : #accessing }
SLVMSAsmValue class >> variable: aVariable [
	^ SLVMSAsmVariable new variable: aVariable
]

{ #category : #testing }
SLVMSAsmValue >> isAggregate [
	^ false
]

{ #category : #testing }
SLVMSAsmValue >> isOperandSet [
	^ false
]

{ #category : #testing }
SLVMSAsmValue >> isRegisterScalarValue [
	^ false
]
