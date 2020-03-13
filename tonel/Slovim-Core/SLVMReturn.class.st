Class {
	#name : #SLVMReturn,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMReturn class >> mnemonic [
	^ #return
]

{ #category : #accessing }
SLVMReturn class >> value: aReturnValue [
	^ self new value: aReturnValue
]

{ #category : #visitor }
SLVMReturn >> accept: aVisitor [
	^ aVisitor visitReturn: self
]

{ #category : #testing }
SLVMReturn >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMReturn >> isReturn [
	^ true
]

{ #category : #testing }
SLVMReturn >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMReturn >> type [
	^ SLVMType voidType
]

{ #category : #evaluating }
SLVMReturn >> value [
	^ parameters first
]

{ #category : #accessing }
SLVMReturn >> value: aValue [
	self parameters: { aValue }
]
