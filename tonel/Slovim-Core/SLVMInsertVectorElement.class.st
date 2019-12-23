Class {
	#name : #SLVMInsertVectorElement,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMInsertVectorElement class >> vector: aVectorValue value: value index: index [
	^ self new vector: aVectorValue value: value index: index
]

{ #category : #printing }
SLVMInsertVectorElement >> accept: aVisitor [
	^ aVisitor visitInsertVectorElement: self
]

{ #category : #printing }
SLVMInsertVectorElement >> index [
	^ parameters second
]

{ #category : #printing }
SLVMInsertVectorElement >> isInsertVectorElement [
	^ true
]

{ #category : #printing }
SLVMInsertVectorElement >> isPureInstruction [
	^ true
]

{ #category : #printing }
SLVMInsertVectorElement >> mnemonic [
	^ #insertelement
]

{ #category : #printing }
SLVMInsertVectorElement >> type [
	^ type
]

{ #category : #printing }
SLVMInsertVectorElement >> value [
	^ parameters third
]

{ #category : #printing }
SLVMInsertVectorElement >> vector [
	^ parameters first
]

{ #category : #'as yet unclassified' }
SLVMInsertVectorElement >> vector: aVectorValue value: value index: index [
	self assert: aVectorValue type isVectorType.
	self parameters: { aVectorValue . value . index}.
	type := aVectorValue type.
]