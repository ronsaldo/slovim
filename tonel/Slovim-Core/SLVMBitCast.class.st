"
I am a casting instruction that just reinterprets the meaning of the input value bits
"
Class {
	#name : #SLVMBitCast,
	#superclass : #SLVMCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMBitCast >> accept: aVisitor [
	^ aVisitor visitBitCast: self
]

{ #category : #testing }
SLVMBitCast >> canBeNop [
	instructionReferences ifEmpty: [ ^ true ].
	instructionReferences size > 1 ifTrue: [ ^ false ].
	instructionReferences first ~~ self nextInstruction ifTrue: [ ^ false ].
	type isDynamicObjectType ~~ self source type isDynamicObjectType ifTrue: [ ^ false ].
	(type isIntegerType and: [ self source type isFloatType ]) ifTrue: [ ^ false ].
	(type isFloatType and: [ self source type isIntegerType ]) ifTrue: [ ^ false ].
	^ true
]

{ #category : #testing }
SLVMBitCast >> isBitCast [
	^ true
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
