Class {
	#name : #SLVMLirInstructionOperand,
	#superclass : #Object,
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'as yet unclassified' }
SLVMLirInstructionOperand >> asLirInstructionOperand [
	^ self
]

{ #category : #testing }
SLVMLirInstructionOperand >> isBasicBlock [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isBlob [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isExternalLabel [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isImmediate [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isImmediateConstant [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isImmediateInInt32Range [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isLabel [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isLabelContentEnd [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isModuleElement [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isRegister [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isRegisterAddress [
	^ false
]

{ #category : #testing }
SLVMLirInstructionOperand >> isRegisterOrRegisterAddress [
	^ self isRegister or: [ self isRegisterAddress ]
]

{ #category : #testing }
SLVMLirInstructionOperand >> isStackFrameVariable [
	^ false
]
