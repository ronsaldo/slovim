Class {
	#name : #SLVMSAsmOperandSet,
	#superclass : #SLVMSAsmValue,
	#instVars : [
		'registers'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #converting }
SLVMSAsmOperandSet >> asSAsmInstructionOperand [
	self assert: self size = 1.
	^ registers first asSAsmInstructionOperand
]

{ #category : #accessing }
SLVMSAsmOperandSet >> at: index [
	^ registers at: index
]

{ #category : #accessing }
SLVMSAsmOperandSet >> collect: aBlock [
	^ registers collect: aBlock
]

{ #category : #accessing }
SLVMSAsmOperandSet >> debugInformation: debugInformation [
	registers do: [ :reg |
		reg debugInformation: debugInformation
	]
]

{ #category : #accessing }
SLVMSAsmOperandSet >> do: aBlock [
	registers do: aBlock
]

{ #category : #accessing }
SLVMSAsmOperandSet >> doWithIndex: aBlock [
	registers doWithIndex: aBlock
]

{ #category : #testing }
SLVMSAsmOperandSet >> isFloatRegister [
	^ self isRegisterScalarValue and: [registers first isFloatRegister]
]

{ #category : #testing }
SLVMSAsmOperandSet >> isFloatingPointRegister [
	^ self isRegisterScalarValue and: [registers first isFloatingPointRegister]
]

{ #category : #testing }
SLVMSAsmOperandSet >> isOperandSet [
	^ true
]

{ #category : #testing }
SLVMSAsmOperandSet >> isRegisterScalarValue [
	^ self size = 1
]

{ #category : #accessing }
SLVMSAsmOperandSet >> registers [
	^ registers
]

{ #category : #accessing }
SLVMSAsmOperandSet >> registers: anObject [
	registers := anObject
]

{ #category : #accessing }
SLVMSAsmOperandSet >> size [
	^ registers size
]
