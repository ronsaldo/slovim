Class {
	#name : #SLVMUnreacheable,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMUnreacheable class >> mnemonic [
	^ #unreachable
]

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

{ #category : #accessing }
SLVMUnreacheable >> type [
	^ SLVMType voidType
]
