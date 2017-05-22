Class {
	#name : #SLVMSAsmVariable,
	#superclass : #SLVMSAsmValue,
	#instVars : [
		'variable'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #converting }
SLVMSAsmVariable >> asSAsmInstructionOperand [
	^ variable
]

{ #category : #testing }
SLVMSAsmVariable >> isAggregate [
	^ true
]

{ #category : #accessing }
SLVMSAsmVariable >> variable [
	^ variable
]

{ #category : #accessing }
SLVMSAsmVariable >> variable: anObject [
	variable := anObject
]
