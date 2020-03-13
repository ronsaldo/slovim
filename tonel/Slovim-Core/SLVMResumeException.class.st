Class {
	#name : #SLVMResumeException,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMResumeException class >> mnemonic [
	^ #resumeException
]

{ #category : #accessing }
SLVMResumeException class >> value: aReturnValue [
	^ self new value: aReturnValue
]

{ #category : #visitor }
SLVMResumeException >> accept: aVisitor [
	^ aVisitor visitResumeException: self
]

{ #category : #testing }
SLVMResumeException >> isResumeException [
	^ true
]

{ #category : #accessing }
SLVMResumeException >> isTerminator [
	^ true
]

{ #category : #accessing }
SLVMResumeException >> type [
	^ SLVMType voidType
]

{ #category : #accessing }
SLVMResumeException >> value [
	^ parameters first
]

{ #category : #accessing }
SLVMResumeException >> value: aValue [
	self parameters: { aValue }
]
