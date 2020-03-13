Class {
	#name : #SLVMDebugInstructionDeclareVariable,
	#superclass : #SLVMDebugInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDebugInstructionDeclareVariable class >> mnemonic [
	^ #dbgDeclareVar
]

{ #category : #accessing }
SLVMDebugInstructionDeclareVariable class >> variable: aVariable [
	^ self new variable: aVariable
]

{ #category : #visiting }
SLVMDebugInstructionDeclareVariable >> accept: aVisitor [
	^ aVisitor visitDebugInstructionDeclareVariable: self
]

{ #category : #accessing }
SLVMDebugInstructionDeclareVariable >> variable [
	^ parameters first
]

{ #category : #accessing }
SLVMDebugInstructionDeclareVariable >> variable: variable [
	self parameters: { variable }
]
