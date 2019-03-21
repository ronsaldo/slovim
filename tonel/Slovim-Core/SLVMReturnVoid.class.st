Class {
	#name : #SLVMReturnVoid,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMReturnVoid >> accept: aVisitor [
	^ aVisitor visitReturnVoid: self
]

{ #category : #testing }
SLVMReturnVoid >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMReturnVoid >> isReturnVoid [
	^ true
]

{ #category : #testing }
SLVMReturnVoid >> isTerminator [
	^ true
]

{ #category : #printing }
SLVMReturnVoid >> mnemonic [
	^ #returnVoid
]

{ #category : #accessing }
SLVMReturnVoid >> type [
	^ SLVMType voidType
]
