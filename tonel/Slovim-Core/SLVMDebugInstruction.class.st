Class {
	#name : #SLVMDebugInstruction,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMDebugInstruction >> isDebugInstruction [
	^ true
]

{ #category : #accessing }
SLVMDebugInstruction >> type [
	^ SLVMType voidType
]
