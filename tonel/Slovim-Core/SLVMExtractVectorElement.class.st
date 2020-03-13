Class {
	#name : #SLVMExtractVectorElement,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMExtractVectorElement class >> mnemonic [
	^ #extractVectorElement
]

{ #category : #'as yet unclassified' }
SLVMExtractVectorElement class >> vector: aVectorValue index: indexValue [
	^ self new vector: aVectorValue index: indexValue
]

{ #category : #visitor }
SLVMExtractVectorElement >> accept: aVisitor [
	^ aVisitor visitExtractVectorElement: self
]

{ #category : #accessing }
SLVMExtractVectorElement >> index [
	^ parameters second
]

{ #category : #testing }
SLVMExtractVectorElement >> isExtractVectorElement [
	^ true
]

{ #category : #testing }
SLVMExtractVectorElement >> isPureInstruction [
	^ true
]

{ #category : #accessing }
SLVMExtractVectorElement >> type [
	^ type
]

{ #category : #accessing }
SLVMExtractVectorElement >> vector [
	^ parameters first
]

{ #category : #accessing }
SLVMExtractVectorElement >> vector: aVectorValue [
	self assert: aVectorValue isVectorType.
	type := aVectorValue baseType.
	self parameters: { aVectorValue }
]

{ #category : #accessing }
SLVMExtractVectorElement >> vector: aVectorValue index: indexValue [
	self assert: aVectorValue type isVectorType.
	type := aVectorValue type baseType.
	self parameters: { aVectorValue . indexValue}
]
