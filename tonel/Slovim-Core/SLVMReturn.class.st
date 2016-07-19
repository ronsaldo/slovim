Class {
	#name : #SLVMReturn,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMReturn class >> value: aReturnValue [
	^ SLVMReturn new value: aReturnValue
]

{ #category : #visitor }
SLVMReturn >> accept: aVisitor [
	^ aVisitor visitReturn: self
]

{ #category : #testing }
SLVMReturn >> isReturn [
	^ true
]

{ #category : #testing }
SLVMReturn >> isTerminator [
	^ true
]

{ #category : #printing }
SLVMReturn >> mnemonic [
	^ 'return'
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
