Class {
	#name : #SLVMBitCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMBitCast >> accept: aVisitor [
	^ aVisitor visitBitCast: self
]

{ #category : #printing }
SLVMBitCast >> mnemonic [
	^ #bitcast
]

{ #category : #'as yet unclassified' }
SLVMBitCast >> source: source targetType: targetType [
	self assert: source type size = targetType size.
	super source: source targetType: targetType.
	
]
