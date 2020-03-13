Class {
	#name : #SLVMReturnVoidFromContext,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMReturnVoidFromContext class >> context: aReturnContext [
	^ self new context: aReturnContext
]

{ #category : #printing }
SLVMReturnVoidFromContext class >> mnemonic [
	^ #returnVoidFromContext
]

{ #category : #visitor }
SLVMReturnVoidFromContext >> accept: aVisitor [
	^ aVisitor visitReturnVoidFromContext: self
]

{ #category : #visitor }
SLVMReturnVoidFromContext >> context: aContext [
	self parameters: { aContext }
]

{ #category : #testing }
SLVMReturnVoidFromContext >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMReturnVoidFromContext >> isReturnVoidFromContext [
	^ true
]

{ #category : #testing }
SLVMReturnVoidFromContext >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMReturnVoidFromContext >> type [
	^ SLVMType voidType
]
