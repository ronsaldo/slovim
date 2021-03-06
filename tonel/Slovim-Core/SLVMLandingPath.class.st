Class {
	#name : #SLVMLandingPath,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'cleanup',
		'catchedExceptions'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMLandingPath class >> mnemonic [
	^ #landingpath
]

{ #category : #'as yet unclassified' }
SLVMLandingPath class >> valueType: aType [
	^ self new type: aType
]

{ #category : #visitor }
SLVMLandingPath >> accept: aVisitor [
	^ aVisitor visitLandingPath: self
]

{ #category : #accessing }
SLVMLandingPath >> catchedExceptions [
	^ catchedExceptions
]

{ #category : #accessing }
SLVMLandingPath >> catchedExceptions: anObject [
	catchedExceptions := anObject
]

{ #category : #accessing }
SLVMLandingPath >> cleanup [
	^ cleanup
]

{ #category : #accessing }
SLVMLandingPath >> cleanup: anObject [
	cleanup := anObject
]

{ #category : #'as yet unclassified' }
SLVMLandingPath >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType.
]

{ #category : #initialization }
SLVMLandingPath >> initialize [
	super initialize.
	cleanup := false.
	catchedExceptions := #().

]

{ #category : #testing }
SLVMLandingPath >> isLandingPath [
	^ true
]

{ #category : #accessing }
SLVMLandingPath >> type [
	^ type
]

{ #category : #accessing }
SLVMLandingPath >> type: anObject [
	type := anObject
]
