Class {
	#name : #SLVMUnreacheable,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMUnreacheable >> accept: aVisitor [
	^ aVisitor visitUnreachable: self
]

{ #category : #testing }
SLVMUnreacheable >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMUnreacheable >> isTerminator [
	^ true
]

{ #category : #testing }
SLVMUnreacheable >> isUnreachable [
	^ true
]

{ #category : #printing }
SLVMUnreacheable >> mnemonic [
	^ #unreachable
]

{ #category : #accessing }
SLVMUnreacheable >> type [
	^ SLVMType voidType
]
