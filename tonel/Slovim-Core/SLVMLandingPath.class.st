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

{ #category : #initialization }
SLVMLandingPath >> initialize [
	super initialize.
	cleanup := false.
	catchedExceptions := #().

]

{ #category : #visitor }
SLVMLandingPath >> mnemonic [
	^ #landingpath
]

{ #category : #accessing }
SLVMLandingPath >> type [
	^ type
]

{ #category : #accessing }
SLVMLandingPath >> type: anObject [
	type := anObject
]
