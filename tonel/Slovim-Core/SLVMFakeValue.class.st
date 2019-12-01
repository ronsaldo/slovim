Class {
	#name : #SLVMFakeValue,
	#superclass : #SLVMValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMFakeValue >> addInstructionReference: anInstruction [
	self error: 'Fake values should not be used.'
]

{ #category : #testing }
SLVMFakeValue >> isFakeValue [
	^ true
]
