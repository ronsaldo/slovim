Class {
	#name : #SLVMReturnFromContext,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMReturnFromContext class >> mnemonic [
	^ #returnFromContext
]

{ #category : #'as yet unclassified' }
SLVMReturnFromContext class >> value: aReturnValue context: aContext [
	^ self new value: aReturnValue context: aContext
]

{ #category : #visitor }
SLVMReturnFromContext >> accept: aVisitor [
	^ aVisitor visitReturnFromContext: self
]

{ #category : #evaluating }
SLVMReturnFromContext >> context [
	^ parameters second
]

{ #category : #testing }
SLVMReturnFromContext >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMReturnFromContext >> isReturnFromContext [
	^ true
]

{ #category : #testing }
SLVMReturnFromContext >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMReturnFromContext >> type [
	^ SLVMType voidType
]

{ #category : #evaluating }
SLVMReturnFromContext >> value [
	^ parameters first
]

{ #category : #accessing }
SLVMReturnFromContext >> value: aReturnValue context: aContext [
	self parameters: { aReturnValue . aContext}
]
