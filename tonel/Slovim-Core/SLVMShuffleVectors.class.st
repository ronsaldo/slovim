Class {
	#name : #SLVMShuffleVectors,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'components'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMShuffleVectors class >> firstVector: firstVector secondVector: secondVector components: components [
	^ self new firstVector: firstVector secondVector: secondVector components: components
]

{ #category : #visitor }
SLVMShuffleVectors >> accept: visitor [
	^ visitor visitShuffleVectors: self
]

{ #category : #accessing }
SLVMShuffleVectors >> components [
	^ components
]

{ #category : #accessing }
SLVMShuffleVectors >> firstVector [
	^ parameters first
]

{ #category : #construction }
SLVMShuffleVectors >> firstVector: firstVector secondVector: secondVector components: arrayOfComponents [
	self parameters: { firstVector . secondVector }.
	self assert: firstVector type isVectorType.
	self assert: secondVector type isVectorType.
	self assert: firstVector type baseType = secondVector type baseType.
	components := arrayOfComponents.
	type := SLVMVectorType baseType: firstVector type baseType elements: components size.
]

{ #category : #printing }
SLVMShuffleVectors >> mnemonic [
	^ #shuffleVectors
]

{ #category : #accessing }
SLVMShuffleVectors >> secondVector [
	^ parameters second
]

{ #category : #accessing }
SLVMShuffleVectors >> type [
	^ type
]