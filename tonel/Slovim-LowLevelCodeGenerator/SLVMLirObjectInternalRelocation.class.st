Class {
	#name : #SLVMLirObjectInternalRelocation,
	#superclass : #SLVMLirObjectRelocation,
	#instVars : [
		'target'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #testing }
SLVMLirObjectInternalRelocation >> isInternalRelocation [
	^ true
]

{ #category : #accessing }
SLVMLirObjectInternalRelocation >> target [
	^ target
]

{ #category : #accessing }
SLVMLirObjectInternalRelocation >> target: anObject [
	target := anObject
]
