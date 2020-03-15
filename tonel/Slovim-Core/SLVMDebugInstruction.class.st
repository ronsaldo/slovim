Class {
	#name : #SLVMDebugInstruction,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMDebugInstruction class >> isAbstract [
	^ self == SLVMDebugInstruction
]

{ #category : #testing }
SLVMDebugInstruction >> isDebugInstruction [
	^ true
]

{ #category : #accessing }
SLVMDebugInstruction >> type [
	^ SLVMType voidType
]
