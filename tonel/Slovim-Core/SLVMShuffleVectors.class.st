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

{ #category : #printing }
SLVMShuffleVectors class >> mnemonic [
	^ #shuffleVectors
]

{ #category : #visitor }
SLVMShuffleVectors >> accept: visitor [
	^ visitor visitShuffleVectors: self
]

{ #category : #accessing }
SLVMShuffleVectors >> components [
	^ components
]

{ #category : #'as yet unclassified' }
SLVMShuffleVectors >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType.
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

{ #category : #testing }
SLVMShuffleVectors >> isPureInstruction [
	^ true
]

{ #category : #testing }
SLVMShuffleVectors >> isShuffleVectors [
	^ true
]

{ #category : #accessing }
SLVMShuffleVectors >> secondVector [
	^ parameters second
]

{ #category : #accessing }
SLVMShuffleVectors >> signature [
	^ super signature , { components }
]

{ #category : #accessing }
SLVMShuffleVectors >> type [
	^ type
]
