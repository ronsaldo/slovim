Class {
	#name : #SLVMLandingPath,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'cleanup'
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
SLVMLandingPath >> cleanup [
	^ cleanup
]

{ #category : #accessing }
SLVMLandingPath >> cleanup: anObject [
	cleanup := anObject
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
