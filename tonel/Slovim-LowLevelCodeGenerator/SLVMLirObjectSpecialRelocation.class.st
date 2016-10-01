Class {
	#name : #SLVMLirObjectSpecialRelocation,
	#superclass : #SLVMLirObjectRelocation,
	#instVars : [
		'specialObject'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #testing }
SLVMLirObjectSpecialRelocation >> isSpecialObjectRelocation [
	^ true
]

{ #category : #accessing }
SLVMLirObjectSpecialRelocation >> specialObject [
	^ specialObject
]

{ #category : #accessing }
SLVMLirObjectSpecialRelocation >> specialObject: anObject [
	specialObject := anObject
]
