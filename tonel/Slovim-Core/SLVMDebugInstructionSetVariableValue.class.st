Class {
	#name : #SLVMDebugInstructionSetVariableValue,
	#superclass : #SLVMDebugInstruction,
	#instVars : [
		'variable'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDebugInstructionSetVariableValue class >> mnemonic [
	^ #dbgSetVariable
]

{ #category : #'initialize-release' }
SLVMDebugInstructionSetVariableValue class >> variable: aVariable value: aValue [
	^ self new variable: aVariable value: aValue
]

{ #category : #visiting }
SLVMDebugInstructionSetVariableValue >> accept: aVisitor [
	^ aVisitor visitDebugInstructionSetVariableValue: self
]

{ #category : #accessing }
SLVMDebugInstructionSetVariableValue >> value [
	^ parameters first
]

{ #category : #accessing }
SLVMDebugInstructionSetVariableValue >> variable [
	^ variable
]

{ #category : #accessing }
SLVMDebugInstructionSetVariableValue >> variable: aVariable value: aValue [
	variable := aVariable.
	self parameters: { aValue }
]
