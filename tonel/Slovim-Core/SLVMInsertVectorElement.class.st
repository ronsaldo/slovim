Class {
	#name : #SLVMInsertVectorElement,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMInsertVectorElement class >> mnemonic [
	^ #insertelement
]

{ #category : #'as yet unclassified' }
SLVMInsertVectorElement class >> vector: aVectorValue value: value index: index [
	^ self new vector: aVectorValue value: value index: index
]

{ #category : #printing }
SLVMInsertVectorElement >> accept: aVisitor [
	^ aVisitor visitInsertVectorElement: self
]

{ #category : #'as yet unclassified' }
SLVMInsertVectorElement >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType.
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
