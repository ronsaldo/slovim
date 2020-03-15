Class {
	#name : #SLVMDiscardFragment,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMDiscardFragment class >> mnemonic [
	^ #discard
]

{ #category : #visiting }
SLVMDiscardFragment >> accept: aVisitor [
	^ aVisitor visitDiscardFragment: self
]

{ #category : #testing }
SLVMDiscardFragment >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMDiscardFragment >> isTerminator [
	^ true
]
