Class {
	#name : #SLVMReturnVoid,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMReturnVoid class >> mnemonic [
	^ #returnVoid
]

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

{ #category : #accessing }
SLVMReturnVoid >> type [
	^ SLVMType voidType
]
